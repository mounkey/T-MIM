class EnablePgcrypto < ActiveRecord::Migration[8.2]; def change; enable_extension "pgcrypto"; end; end
