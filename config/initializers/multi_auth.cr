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

# Google omits "canonicalForm" from phone numbers it can't normalize to
# E.164, which makes multi_auth's Google provider crash with
# `Missing hash key: "canonicalForm"` during sign-in (still the case in
# multi_auth 1.2.0). Fill it in from "value" before multi_auth reads it.
class MultiAuth::Provider::Google
  private def build_user(raw_json, access_token)
    data = JSON.parse(raw_json)

    if phones = data["phoneNumbers"]?.try(&.as_a?)
      phones.each do |phone|
        number = phone.as_h
        number["canonicalForm"] ||= number["value"]? || JSON::Any.new("")
      end
      raw_json = data.to_json
    end

    previous_def(raw_json, access_token)
  end
end
