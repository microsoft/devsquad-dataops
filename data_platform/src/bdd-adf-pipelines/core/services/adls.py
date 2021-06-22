from azure.core.paging import ItemPaged
from azure.storage.filedatalake import *
from typing import List
import os

class Adls:
  def __init__(self, storage_account_name: str, storage_account_key: str) -> None:
    self.client: DataLakeServiceClient = self.get_client(storage_account_name, storage_account_key)
    
  def get_client(self, storage_account_name: str, storage_account_key: str) -> DataLakeServiceClient:
    account_url: str = f"https://{storage_account_name}.dfs.core.windows.net"
    return DataLakeServiceClient(account_url, storage_account_key)

  def container_exists(self, container_name: str) -> bool:
    file_system_client: FileSystemClient = self.client.get_file_system_client(container_name)
    return file_system_client is not None

  def get_latest_log_content(self, container_name: str, directory_name: str) -> str:
    file_system_client: FileSystemClient = self.client.get_file_system_client(container_name)
    directory_client: DataLakeDirectoryClient = file_system_client.get_directory_client(directory_name)
    log_file_name: str = self.get_latest_log_file_name(file_system_client, directory_name)

    return self.get_log_content(directory_client, log_file_name)

  def get_latest_log_file_name(self, file_system_client: FileSystemClient, directory_name: str) -> str:
    paths: ItemPaged = file_system_client.get_paths(directory_name)

    if not paths:
      raise Exception("No log files were found.")

    file_names: List[str] = [path.name for path in paths]
    return os.path.basename(file_names[-1])

  def get_log_content(self, directory_client: DataLakeDirectoryClient, log_file_name: str) -> str:
    file_client: DataLakeFileClient = directory_client.get_file_client(log_file_name)
    downloader: StorageStreamDownloader = file_client.download_file()
    content_bytes: bytes = downloader.readall()

    return content_bytes.decode("utf-8")
