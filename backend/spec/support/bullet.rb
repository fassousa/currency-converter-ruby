# frozen_string_literal: true

# Bullet configuration for N+1 query detection in tests
if Bullet.enable?
  Bullet.bullet_logger = true
  Bullet.raise = true # Raise an error when N+1 query detected in tests
  
  # Bullet detection settings
  Bullet.n_plus_one_query_enable     = true
  Bullet.unused_eager_loading_enable = true
  Bullet.counter_cache_enable        = false
  
  # Alert methods
  Bullet.alert                = false
  Bullet.console              = true
  Bullet.rails_logger         = true
  Bullet.add_footer           = false
end
