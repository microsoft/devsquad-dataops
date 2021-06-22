class ServicePrincipal:
  def __init__(self, client_id: str, client_secret: str, subscription_id: str, tenant_id: str):
    self.client_id = client_id
    self.client_secret = client_secret
    self.subscription_id = subscription_id
    self.tenant_id = tenant_id
