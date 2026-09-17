# frozen_string_literal: true

Grover.configure do |config|
  config.options = {
    format: 'A4',
    margin: {
      top: '5px',
      bottom: '5px',
      left: '5px',
      right: '5px'
    },
    user_agent: 'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0',
    viewport: {
      width: 640,
      height: 480
    },
    prefer_css_page_size: true,
    emulate_media: 'screen',
    bypass_csp: true,
    media_features: [{ name: 'prefers-color-scheme', value: 'light' }],
    timezone: 'America/Santiago', # Adjust as needed
    vision_deficiency: 'deuteranopia',
    extra_http_headers: { 'Accept-Language' => 'es-ES' },
    # cache: false,
    timeout: 60000, # ms
    # request_timeout: 1000, # ms
    # convert_timeout: 2000, # ms
    launch_args: ['--no-sandbox', '--disable-setuid-sandbox', '--font-render-hinting=medium', '--lang=es-ES'],
    wait_until: 'domcontentloaded'
  }
end
