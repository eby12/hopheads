class Post < ActiveRecord::Base
  attr_accessor   :image_file_name, :image_content_type
  attr_accessible :image_file_name, :image_content_type
  has_attached_file :image, styles: { medium: '300x300>', thumb: '100x100>' },
    path: ':rails_root/public/attachments/:class/:id_partition/:style/:filename',
    url:  'attachments/:class/:id_partition/:style/:filename'

  attr_accessible :title, :beer_attributes, :brewery_attributes, :location_attributes, :style_attributes, :image

  before_validation :lookup_beer,    if: proc { !self.beer.nil? }
  before_validation :lookup_brewery, if: proc { !self.brewery.nil? }
  before_validation :lookup_location, if: proc { !self.location.nil? }
  before_validation :lookup_style, if: proc { !self.style.nil? }

  belongs_to :user
  belongs_to :beer
  belongs_to :location
  belongs_to :brewery
  belongs_to :style

  has_many :comments, dependent: :destroy

  accepts_nested_attributes_for :beer, :brewery, :location, :style

  default_scope order('created_at DESC')

  validates :user, presence: true
  #validates :title, length: {minimum: 5}, presence: true
  #validates_attachment_presence :image
  #validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  #This method looks up if a brewery exists already. If it doesn't it creates a new Brewery, if it does then it references the one in the database.
  def lookup_brewery
    brewery = Brewery.where(name: self.brewery.name).first
    self.brewery = brewery if brewery
    else
    self.brewery.beers << self.beer
  end
  #This method looks up if a beer exists already. If it doesn't it creates a new Beer, if it does then it references the one in the database.
  def lookup_beer
    beer = Beer.where(name: self.beer.name).first
    self.beer = beer if beer
  end
  def lookup_style
    style = Style.where(name: self.style.name).first
    self.style = style if style
    else
    self.style.beers << self.beer
  end
  #This method looks up if the location exists.
  def lookup_location
    location = Location.where(address: self.location.address).first
    self.location = location if location
    if self.brewery.location == nil
      self.brewery.location = self.location
    end
  end
end