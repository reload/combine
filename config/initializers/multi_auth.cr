require "multi_auth"

MultiAuth.config(
  "google",
  Amber.settings.secrets["google_client_id"],
  Amber.settings.secrets["google_client_secret"],
)

class HTTP::Client
  def_around_exec do |request|
    # OAuth callback request would fail because the Content-Length
    # header didn't match the amount of body bytes written. The
    # problem was that
    # Amber::Router::Parsers::FormData.parse_part(input : IO) would
    # read the request.body and put the position at the end of the
    # buffer, so when HTTP.serialize_headers_and_body tried to read
    # it, it would get 0 bytes. FormData.parse_part is called due to
    # HTTP::Request#requested_method (from Amber) calling
    # FormData.override_method?, which in turn is caused by http/log.
    # We fix this by just rewinding the body IO::Memory before passing
    # it on to HTTP::Client#exec_internal (as this is defined after
    # http/logs def_around_exec, it gets the request afterwards).
    request.body.try &.rewind
    yield
  end
end

class Amber::Server
  # Monkeypatch Amber::Server to always make SSL links. We're running
  # behind Traefik in production.
  def scheme
    ssl_enabled? ? "https" : "http"
  end
end
