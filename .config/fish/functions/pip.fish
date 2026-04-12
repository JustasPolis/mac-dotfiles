function pip
    echo "pip is blocked. Use uv instead:" >&2
    echo "  uv add <pkg>          # add to project" >&2
    echo "  uv tool install <pkg> # install CLI tool" >&2
    echo "  uv pip install <pkg>  # pip-compatible (venv only)" >&2
    return 1
end
