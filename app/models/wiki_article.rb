class WikiArticle < ApplicationRecord
  acts_as_tenant :account, optional: true

  validates :title, presence: true
  validates :content, presence: true

  # Las guías globales de T-MIM son accesibles por todos los tenants (unscoped de tenant)
  scope :global_articles, -> { unscoped.where(is_global: true).order(:position, :title) }
  scope :company_articles, -> { where(is_global: false).order(:category, :title) }
end
