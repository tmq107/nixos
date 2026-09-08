{ ... }:
{
  programs.firefox = {
    enable = true;

    profiles.default = {
      isDefault = true;

      bookmarks = {
        force = true;
        settings = [
          {
            name = "Bookmarks Toolbar";
            toolbar = true;
            bookmarks = import ./bookmarks.nix;
          }
        ];
      };

      userChrome = ''
        /* userChrome.css — Firefox UI customization
         * Requires: toolkit.legacyUserProfileCustomizations.stylesheets = true
         * Restart Firefox after changes.
         */

        @namespace url("http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul");

        /* ── Hide horizontal tab bar when vertical tabs active ──────────────────────── */
        :root[sidebar-revamp] #TabsToolbar {
          display: none !important;
        }

        /* ── Hide tab close button until hover ─────────────────────────────────────── */
        .tabbrowser-tab:not([selected]):not(:hover) .tab-close-button {
          display: none !important;
        }

        /* ── Compact tab bar height ────────────────────────────────────────────────── */
        :root {
          --tab-min-height: 32px !important;
        }

        /* ── Slim scrollbars ────────────────────────────────────────────────────────── */
        :root {
          scrollbar-width: thin;
        }
      '';

      userContent = ''
        /* userContent.css — Firefox webpage overrides
         * Applies to web content, not the browser UI.
         */

        /* ── Force dark background on plain text / about: pages ────────────────────── */
        @-moz-document url-prefix("about:") {
          :root {
            color-scheme: dark;
          }
        }
      '';

      settings = {
        # Stylesheets
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # UI / UX
        "layout.css.devPixelsPerPx" = "1.20";
        "browser.display.base_font_size" = 18;
        "browser.tabs.tabMinWidth" = 0;
        "browser.tabs.tabClipWidth" = 83;
        "browser.tabs.hoverPreview.enabled" = true;
        "browser.urlbar.trimURLs" = false;
        "browser.urlbar.suggest.searches" = false;
        "browser.search.suggest.enabled" = false;
        "browser.newtabpage.enabled" = false;
        "browser.startup.homepage" = "https://www.google.com";
        "browser.startup.page" = 1;

        # Privacy
        "privacy.donottrackheader.enabled" = true;
        "privacy.globalprivacycontrol.enabled" = true;
        "privacy.query_stripping.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "geo.enabled" = false;
        "media.peerconnection.enabled" = false;

        # Telemetry
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "browser.ping-centre.telemetry" = false;
        "app.shield.optoutstudies.enabled" = false;

        # Vertical tabs (Firefox 131+)
        "sidebar.revamp" = true;
        "sidebar.verticalTabs" = true;
        "sidebar.main.tools" = "history,bookmarks";
        "browser.ml.chat.enabled" = false;

        # Performance
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;
      };
    };
  };
}
