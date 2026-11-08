# gopass Onboarding: age + Forgejo HTTPS + Local-Only Vault

This runbook documents the gopass setup used on Linux: one age-encrypted Git-backed root store synced manually to a private Forgejo repository, plus a separate age-encrypted local-only store. It also covers credential use, agent PIN caching, and troubleshooting.

> **Security:** Never paste age private keys, Forgejo access tokens, or secret values into Git, documentation, issue trackers, or chat. Do not reset an existing store without making a verified backup.
>
> **Compatibility:** gopass's age backend is currently marked **experimental** by its maintainers. Commands shown are intended for recent gopass versions (prefer v1.17.4 or newer).

## 1. Target architecture

```text
                                  gopass CLI
                                      |
                      +---------------+---------------+
                      |                               |
        root store: "gopass"                 mount: "local"
        ~/personal/password-store            ~/personal/password-local
        crypto: age                          crypto: age
        storage: gitfs                       storage: fs
                      |                               |
           Git commits + manual push             no Git repository
                      |
         Private Forgejo repository (HTTPS)
         https://git.mquanthai.com/tmq107/gopass.git
```

- Entries such as `cloudflare/token` go to the root, Forgejo-backed store.
- Entries such as `local/database/password` go to the **local** mount and stay off the remote.
- Both stores are accessible through a single `gopass` command.
- Git commits are created locally; **auto-push and auto-sync are disabled**.

## 2. Prerequisites

Install `gopass`, `age` (including `age-keygen`), and `git` through your Linux package manager.

```bash
gopass version
age-keygen --version
git --version
```

For NixOS, declare `gopass`, `age`, and `git` in your NixOS or Home Manager packages and apply your configuration. Prefer an updated package with age-agent fixes.

## 3. Prepare your existing age key

If your age private identity is already saved at `~/.config/age/keys.txt`, derive its **public recipient**:

```bash
age-keygen -y ~/.config/age/keys.txt
```

The result begins with `age1...`. The private key begins with `AGE-SECRET-KEY-1...` and **must stay private**.

If you have only the private key text, create a protected identity file:

```bash
mkdir -p ~/.config/age
chmod 700 ~/.config/age
umask 077
cat > ~/.config/age/keys.txt
# Paste the private identity, then press Ctrl+D.
chmod 600 ~/.config/age/keys.txt
```

Import the existing identity into gopass's age keyring:

```bash
gopass age identities add
```

Follow its prompts for the private identity and corresponding public recipient. Check the imported identity without printing your private key:

```bash
gopass age identities
```

For subsequent commands, replace `age1YOUR_PUBLIC_RECIPIENT` with the actual `age1...` value from `age-keygen -y`.

## 4. Initialize the root Git-backed store in a custom directory

**Do this only on a fresh machine without an existing configured root store.** If `gopass mounts` already shows the intended root path, skip initialization.

```bash
mkdir -p "$HOME/personal"

gopass init \
  --crypto age \
  --storage gitfs \
  --path "$HOME/personal/password-store" \
  age1YOUR_PUBLIC_RECIPIENT
```

Verify:

```bash
gopass mounts
gopass ls
gopass git status
```

Expected root path: `/home/quanthai/personal/password-store` (or the equivalent under your `$HOME`).

### If you want to clone password-store repo to other machines, please use below command

```bash
gopass clone \
  --crypto age \
  --path "$HOME/personal/password-store" \
  https://git.mquanthai.com/tmq107/password-store.git
```

## 5. Create a private, EMPTY Forgejo repository

In Forgejo, create a private repository named `gopass` under `tmq107`. During creation, **do not** add a README, license, or `.gitignore`; these generate an initial commit and can make the first push non-fast-forward.

The HTTPS clone URL is:

```text
https://git.mquanthai.com/tmq107/gopass.git
```

**Note:** A colon after the domain means a numeric TCP port, not the username. The URL is `...com/tmq107/...`, not `...com:tmq107/...`.

Create a Forgejo Personal Access Token with appropriate repository read/write permissions in **Settings -> Applications**. Keep it outside Git. HTTPS Git can use your Forgejo username and this token as its password.

Optional: cache HTTPS Git credentials in memory for eight hours (not persistently on disk):

```bash
git config --global credential.helper 'cache --timeout=28800'
```

## 6. Connect root store to Forgejo and push once

```bash
gopass git remote add origin \
  https://git.mquanthai.com/tmq107/gopass.git

gopass git remote -v
gopass git status

gopass git push -u origin HEAD
```

Use the Forgejo username and token if Git prompts for credentials. `HEAD` pushes the current local branch (commonly `master`); it avoids hard-coding a branch name.

If `origin` already exists, inspect it and change only if needed:

```bash
gopass git remote -v
gopass git remote set-url origin \
  https://git.mquanthai.com/tmq107/gopass.git
```

### If the first push is rejected (`fetch first` or `non-fast-forward`)

The remote likely has an initial README commit or other changes. **Do not force-push without checking**. For a disposable, truly empty new remote, recreate it in Forgejo without initialization. Otherwise integrate its history carefully:

```bash
gopass git fetch origin
gopass git log --oneline --graph --all -10
# Only if you intend to retain both unrelated histories:
gopass git merge origin/master --allow-unrelated-histories
# Resolve any conflicts before pushing.
gopass git push -u origin HEAD
```

Replace `master` with the remote's branch if different. On first setup, recreating an empty remote is usually simpler than merging unrelated histories.

## 7. Disable automatic Git pushes and synchronization

```bash
gopass config core.autopush false
gopass config core.autosync false

gopass config core.autopush
gopass config core.autosync
```

Both should print `false`.

The resulting workflow is **manual**:

```bash
# Review local commits and working tree
gopass git status
gopass git log --oneline -5

# Push root-store commits when YOU choose
gopass git push

# Fetch and merge remote changes when YOU choose
gopass git pull

# Explicitly synchronize (includes pull/push)
gopass sync
```

`gopass` still records local Git history for root-store changes; disabling automatic push does not disable local commits.

## 8. Create the local-only mounted store

```bash
gopass init \
  --store local \
  --path "$HOME/personal/password-local" \
  --crypto age \
  --storage fs \
  age1YOUR_PUBLIC_RECIPIENT
```

Verify:

```bash
gopass mounts
```

Expected layout:

```text
gopass (/home/quanthai/personal/password-store)
└── local (/home/quanthai/personal/password-local)
```

Check that the local mount is not inside the root Git repository:

```bash
git -C "$HOME/personal/password-store" status

git -C "$HOME/personal/password-local" rev-parse --is-inside-work-tree
# Normally reports: not a git repository
```

**Important:** `gopass mounts` shows locations, but does not by itself prove which storage backend is in use. The local mount must have been initialized with `--storage fs` and should not be inside another tracked Git working tree.

### Why not use `.gitignore`?

A Git push is **repository/commit scoped**, not folder scoped; it cannot push just `personal/` while skipping previously committed changes in `work/`. A `.gitignore` file is also not a reliable confidentiality boundary: ignored files can still be explicitly force-added, and previously tracked files are unaffected. A separate `fs` mount is a stronger isolation mechanism.

## 9. Daily secret operations

| Task | Command |
| --- | --- |
| List all vaults | `gopass mounts` |
| List secrets | `gopass ls` |
| Add Forgejo-backed secret | `gopass insert cloudflare/token` |
| Add local-only secret | `gopass insert local/database/password` |
| Show root secret | `gopass show cloudflare/token` |
| Show local secret | `gopass show local/database/password` |
| Copy secret to clipboard | `gopass show -c cloudflare/token` |
| Edit secret | `gopass edit cloudflare/token` |
| Delete secret | `gopass rm cloudflare/token` |
| Delete local secret | `gopass rm local/database/password` |
| Check root Git status | `gopass git status` |
| Push root to Forgejo | `gopass git push` |
| Pull root from Forgejo | `gopass git pull` |

Example shell export:

```bash
export CLOUDFLARE_API_TOKEN="$(gopass show cloudflare/token)"
# Run the command that needs the token, then:
unset CLOUDFLARE_API_TOKEN
```

Shell environment variables can be read by child processes and sometimes privileged local inspection tools. Avoid printing them, turning on shell tracing (`set -x`), or leaving them around longer than needed.

For the local store:

```bash
gopass insert local/example/token
gopass show local/example/token
gopass rm local/example/token
```

Deleting a Git-backed secret does **not** scrub its older encrypted ciphertext from Git history. Rotate any exposed credentials at the provider.

## 10. age agent: avoid entering the PIN for every secret

Use an updated version of gopass (v1.17.4 or newer is recommended for this workflow). Earlier v1.16.1 installations were observed to request a PIN every time even with an agent running.

```bash
gopass version
gopass config age.agent-enabled true
# Cache identities for one hour of inactivity
gopass config age.agent-timeout 3600

gopass age agent status
```

After changing gopass versions, restart/unlock the agent:

```bash
gopass age agent stop
gopass age agent unlock
```

Test without printing the secret:

```bash
gopass show cloudflare/token >/dev/null
gopass show cloudflare/token >/dev/null
```

The first read may request the keyring PIN; the next read should reuse the unlocked session. To clear the cache:

```bash
gopass age agent lock
```

A timeout of `0` disables **idle auto-lock**, **not** the initial PIN challenge. Leaving an unlocked agent indefinitely increases risk on a shared/unlocked workstation. Some age hardware-backed identity types have additional authentication behavior.

## 11. Onboard a second machine

1. Install updated `gopass`, `age`, and `git`.
2. Securely import the authorized age **private identity** into gopass (do not store the private key in Forgejo).
3. Ensure HTTPS Git authentication works with your Forgejo account/token.
4. Clone the existing root store instead of running `gopass init` again:

```bash
gopass age identities add

gopass clone \
  https://git.mquanthai.com/tmq107/gopass.git

gopass mounts
gopass ls
```

The default path on the new machine may differ. Use `gopass clone --help` to choose a supported custom destination/mount for your installed version. Set auto-push and auto-sync off there as well.

The local-only `fs` vault is **not** transferred by cloning Forgejo. Create a new local mount on the new machine if needed, or back up/restore it separately via a secure method.

## 12. Troubleshooting reference

| Symptom | Cause / next action |
| --- | --- |
| `URL rejected: Port number was not a decimal number` | Wrong URL such as `https://host:username/repo.git`; use `https://host/username/repo.git`. |
| Git push hangs or asks for credentials | Test `git ls-remote origin` inside the root store; check HTTPS reachability, token, and credential helper. |
| Push rejected as `fetch first` | Remote has commits not present locally; inspect history, then merge or recreate an empty disposable remote. Avoid force push. |
| `git pull` says no tracking branch | First establish upstream using `gopass git push -u origin HEAD` after histories are reconciled. |
| `gopass git status` shows an unexpected location | gopass operates on the **configured store**, not the shell's current directory. Check `gopass mounts`. |
| `gopass mounts` says `No mounts` | There are no *additional* mounts; the root store may still be working. |
| PIN requested every time | Update gopass; check `gopass age agent status`, enable agent and restart/unlock it. |
| Some secrets appear in Forgejo unexpectedly | Confirm paths are in different stores, and inspect old Git commits; `.gitignore` does not erase already committed files. |

For detailed HTTPS diagnostics (run in the root-store directory):

```bash
cd "$HOME/personal/password-store"
GIT_TERMINAL_PROMPT=0 timeout 15s git ls-remote origin
```

If authentication is missing, Git should report that it cannot prompt for credentials; if the network is inaccessible, the command may time out.

## 13. Official references

- [gopass GitHub](https://github.com/gopasspw/gopass)
- [gopass setup and Git synchronization](https://github.com/gopasspw/gopass/blob/master/docs/setup.md)
- [gopass age backend (experimental)](https://github.com/gopasspw/gopass/blob/master/docs/backends/age.md)
- [gopass mounts and custom store paths](https://github.com/gopasspw/gopass/blob/master/docs/features.md)
- [gopass config: autopush, autosync, and age agent](https://github.com/gopasspw/gopass/blob/master/docs/config.md)

