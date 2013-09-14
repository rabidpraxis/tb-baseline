# Configure the TorqueBox Servlet-based session store.
# Provides for server-based, in-memory, cluster-compatible sessions
TbBaseline::Application.config.session_store :cookie_store, :key => '_CHANGEME_session'
