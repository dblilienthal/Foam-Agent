# config.py
import os
from dataclasses import dataclass, field
from pathlib import Path

@dataclass
class Config:
    max_loop: int = 10
    
    batchsize: int = 10
    searchdocs: int = 2
    run_times: int = 1  # current run number (for directory naming)
    database_path: str = Path(__file__).resolve().parent.parent / "database"
    run_directory: str = Path(__file__).resolve().parent.parent / "runs"
    case_dir: str = ""
    max_time_limit: int = 3600 # Max time limit after which the openfoam run will be terminated, in seconds
    file_dependency_threshold: int = 3000 # threshold length on the similar case; see `nodes/architect_node.py` for details
    model_provider: str = field(default_factory=lambda: os.environ.get("MODEL_PROVIDER", "openai"))  # [openai, azure_openai, ollama, bedrock]
    # model_version should be in ["gpt-5-mini", "deepseek-r1:32b-qwen-distill-fp16", "qwen2.5:32b-instruct"]
    model_version: str = field(default_factory=lambda: os.environ.get("MODEL_VERSION", "gpt-5-mini"))
    temperature: float = 1
    
    # Azure OpenAI specific configuration (only used when model_provider="azure_openai")
    # These can be set via environment variables for Docker usage:
    #   AZURE_OPENAI_ENDPOINT, AZURE_OPENAI_DEPLOYMENT_NAME, AZURE_OPENAI_API_VERSION,
    #   AZURE_OPENAI_MODEL_NAME, AZURE_OPENAI_EMBEDDING_DEPLOYMENT_NAME
    azure_endpoint: str = field(default_factory=lambda: os.environ.get("AZURE_OPENAI_ENDPOINT", ""))  # e.g., "https://your-resource.openai.azure.com/"
    azure_deployment_name: str = field(default_factory=lambda: os.environ.get("AZURE_OPENAI_DEPLOYMENT_NAME", ""))  # The deployment name you chose in Azure
    azure_api_version: str = field(default_factory=lambda: os.environ.get("AZURE_OPENAI_API_VERSION", "2024-12-01-preview"))  # Azure OpenAI API version
    azure_model_name: str = field(default_factory=lambda: os.environ.get("AZURE_OPENAI_MODEL_NAME", ""))  # Actual model name for token counting (e.g., "gpt-4o-mini")
    azure_embedding_deployment_name: str = field(default_factory=lambda: os.environ.get("AZURE_OPENAI_EMBEDDING_DEPLOYMENT_NAME", ""))  # Deployment name for embeddings (e.g., "text-embedding-3-small")
