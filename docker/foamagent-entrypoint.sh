#!/bin/bash
set -e

# Source OpenFOAM environment in a controlled way: allow non-zero RC, then validate
set +e
source /opt/openfoam10/etc/bashrc
openfoam_rc=$?
set -e

# Strict validation: must have WM_PROJECT_DIR and blockMesh in PATH
if [ -z "$WM_PROJECT_DIR" ] || ! command -v blockMesh >/dev/null 2>&1; then
    echo "ERROR: OpenFOAM environment failed to load (rc=$openfoam_rc)." >&2
    echo "Diag: WM_PROJECT_DIR='${WM_PROJECT_DIR:-unset}', blockMesh=$(command -v blockMesh || echo 'NOT-IN-PATH')" >&2
    exit 1
fi

# Initialize conda
source "$CONDA_DIR/etc/profile.d/conda.sh"

# Activate FoamAgent environment
conda activate FoamAgent

# Change to Foam-Agent directory
cd "$FoamAgent_PATH"

# Display welcome message
echo "=========================================="
echo "Foam-Agent Docker Container Ready!"
echo "=========================================="
echo "OpenFOAM: $WM_PROJECT_DIR"
echo "Conda Env: FoamAgent (activated)"
echo "Working Dir: $FoamAgent_PATH"
echo ""
echo "To update to latest Foam-Agent:"
echo "  cd $FoamAgent_PATH && git pull"
echo ""
echo "To run Foam-Agent:"
echo "  python foambench_main.py --output ./output --prompt_path ./user_requirement.txt"
echo ""

# Display LLM provider configuration
echo "--- LLM Provider Configuration ---"
if [ -n "$MODEL_PROVIDER" ]; then
    echo "MODEL_PROVIDER: $MODEL_PROVIDER"
else
    echo "MODEL_PROVIDER: openai (default)"
fi

if [ -n "$MODEL_VERSION" ]; then
    echo "MODEL_VERSION: $MODEL_VERSION"
else
    echo "MODEL_VERSION: gpt-5-mini (default)"
fi

# Check for standard OpenAI key
if [ -n "$OPENAI_API_KEY" ]; then
    echo "OPENAI_API_KEY: ${OPENAI_API_KEY:0:8}... (set)"
else
    echo "OPENAI_API_KEY: (not set)"
fi

# Check for Azure OpenAI configuration
if [ "${MODEL_PROVIDER}" = "azure_openai" ] || [ -n "$AZURE_OPENAI_ENDPOINT" ]; then
    echo ""
    echo "--- Azure OpenAI Configuration ---"
    if [ -n "$AZURE_OPENAI_API_KEY" ]; then
        echo "AZURE_OPENAI_API_KEY: ${AZURE_OPENAI_API_KEY:0:8}... (set)"
    else
        echo "AZURE_OPENAI_API_KEY: (not set) ⚠️"
    fi
    if [ -n "$AZURE_OPENAI_ENDPOINT" ]; then
        echo "AZURE_OPENAI_ENDPOINT: $AZURE_OPENAI_ENDPOINT"
    else
        echo "AZURE_OPENAI_ENDPOINT: (not set) ⚠️"
    fi
    if [ -n "$AZURE_OPENAI_DEPLOYMENT_NAME" ]; then
        echo "AZURE_OPENAI_DEPLOYMENT_NAME: $AZURE_OPENAI_DEPLOYMENT_NAME"
    else
        echo "AZURE_OPENAI_DEPLOYMENT_NAME: (not set) ⚠️"
    fi
    if [ -n "$AZURE_OPENAI_API_VERSION" ]; then
        echo "AZURE_OPENAI_API_VERSION: $AZURE_OPENAI_API_VERSION"
    else
        echo "AZURE_OPENAI_API_VERSION: 2024-12-01-preview (default)"
    fi
    if [ -n "$AZURE_OPENAI_MODEL_NAME" ]; then
        echo "AZURE_OPENAI_MODEL_NAME: $AZURE_OPENAI_MODEL_NAME"
    else
        echo "AZURE_OPENAI_MODEL_NAME: (not set, will use MODEL_VERSION for token counting)"
    fi
    if [ -n "$AZURE_OPENAI_EMBEDDING_DEPLOYMENT_NAME" ]; then
        echo "AZURE_OPENAI_EMBEDDING_DEPLOYMENT_NAME: $AZURE_OPENAI_EMBEDDING_DEPLOYMENT_NAME"
    else
        echo "AZURE_OPENAI_EMBEDDING_DEPLOYMENT_NAME: (not set) ⚠️"
    fi
fi

echo ""
echo "Note: Config is read from environment variables at runtime."
echo "      See README.md for docker run examples."
echo "=========================================="

# Execute the command passed to the container
if [ "$1" = "/bin/bash" ] || [ "$1" = "bash" ] || [ -z "$1" ]; then
    exec /bin/bash -i
else
    exec "$@"
fi
