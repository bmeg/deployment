# Do not forget to pin down the version
FROM jupyterhub/jupyterhub:1.0.0

# OLD: Copy the JupyterHub configuration in the container
  # COPY jupyterhub_config.py .
# NEW: map as volume -> /srv/jupyterhub/jupyterhub_config.py

# Download script to automatically stop idle single-user servers
RUN wget https://raw.githubusercontent.com/jupyterhub/jupyterhub/1.0.0/examples/cull-idle/cull_idle_servers.py

# Install dependencies (for advanced authentication and spawning)
RUN pip install \
    dockerspawner==0.11.1 \
    oauthenticator==0.8.2
