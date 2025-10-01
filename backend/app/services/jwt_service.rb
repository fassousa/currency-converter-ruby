class JwtService
  ALGORITHM = 'HS256'

  # Encode a payload into a JWT. `exp` may be a Time, Integer (unix), or nil.
  # When running outside Rails, fall back to Time.now + 24h.
  def self.encode(payload, exp = nil)
    exp ||= (defined?(ActiveSupport) ? 24.hours.from_now : Time.now + 24 * 3600)
    payload[:exp] = exp.to_i
    require 'jwt' unless defined?(JWT)
    JWT.encode(payload, secret, ALGORITHM)
  end

  # Decode a token and return a hash-like payload. Returns nil on failure.
  def self.decode(token)
    return nil unless token
    require 'jwt' unless defined?(JWT)
    decoded = JWT.decode(token, secret, true, algorithm: ALGORITHM)
    payload = decoded.first
    # Prefer ActiveSupport's HashWithIndifferentAccess when available
    if defined?(ActiveSupport::HashWithIndifferentAccess)
      ActiveSupport::HashWithIndifferentAccess.new(payload)
    else
      payload
    end
  rescue JWT::ExpiredSignature, JWT::DecodeError
    nil
  end

  def self.secret
    ENV.fetch('JWT_SECRET_KEY', 'change_me_locally')
  end
end
