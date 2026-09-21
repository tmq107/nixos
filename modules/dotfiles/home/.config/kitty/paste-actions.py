def filter_paste(text: str) -> str:
    """Normalize Windows clipboard line endings without changing Linux LF text."""
    return text.replace("\r\n", "\n")
