require "spec_helper"
require "rack/test"
require_relative '../../app'

describe Application do
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  def reset_tables
  seed_sql = File.read('spec/seeds/music_library.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_test' })
  connection.exec(seed_sql)
  end

  before(:each) do 
    reset_tables
  end

  # context "GET /" do
  #   xit "returns an hello page if the password is correct" do
  #     response = get("/", password: 'abcd')

  #     expect(response.status).to eq 200
  #     expect(response.body).to include("Hello!")
  #   end
    
  #   xit "returns a forbidden page if the password is incorrect" do
  #     response = get("/", password: 'abcaksdlkajsdlkjoid')

  #     expect(response.status).to eq 200
  #     expect(response.body).to include("Access Forbidden!")
  #   end
  # end

  context "GET /albums" do
    it "should return the links to the albums" do
      response = get("/albums")
      
      expect(response.status).to eq 200
      expect(response.body).to include('<a href="/albums/1">Doolittle</a><br/>')
      expect(response.body).to include('<a href="/albums/2">Surfer Rosa</a><br/>')
      expect(response.body).to include('<a href="/albums/3">Waterloo</a><br/>')
      expect(response.body).to include('<a href="/albums/12">Ring Ring</a><br/>')
    end
  end

  context "GET /albums/:id" do
    it "should return info of the album 1" do
      response = get("/albums/1")
      
      expect(response.status).to eq 200
      expect(response.body).to include('<h1>Doolittle</h1>')
      expect(response.body).to include('Release year: 1989')
      expect(response.body).to include('Artist: Pixies')
    end
  end
  
  context "GET /albums/:id" do
    it "should return info of the album 2" do
      response = get("/albums/2")
      
      expect(response.status).to eq 200
      expect(response.body).to include('<h1>Surfer Rosa</h1>')
      expect(response.body).to include('Release year: 1988')
      expect(response.body).to include('Artist: Pixies')
    end
  end

  context "GET /albums/new" do
    it "should return the form to add a new album" do
      response = get("/albums/new")

      expect(response.status).to eq 200
      expect(response.body).to include('<form method="POST" action="/albums">')
      expect(response.body).to include('<input type="text" name="title" />')
      expect(response.body).to include('<input type="text" name="release_year" />')
    end
  end
  
  context "POST /albums" do
    it "should validate album parameters" do
      response = post("/albums", 
        invalid_artist_title: 'OK Computer', 
        another_invalid_parameter: 'invalid parameter'
      )  

      expect(response.status).to eq(400) 
    end
    
    
    it "should add a new album" do 
      response = post(
        '/albums', 
        title: 'Voyage', 
        release_year: '2022', 
        artist_id: '2'
      )
      expect(response.status).to eq(200)
      expect(response.body).to eq("")
      
      response = get("/albums")
      
      expect(response.body).to include("Voyage")
    end 
  end
  
  context "GET /artists" do
    it "should return the list of artists" do
      response = get("/artists")
      
      expect(response.status).to eq 200
      expect(response.body).to include('<a href="/artists/1">Pixies</a>')
    end
  end

  context "GET /artists/:id" do
    it "returns the info of the artist 'Pixies'" do
      response = get("/artists/1")

      expect(response.status).to eq 200
      expect(response.body).to include('<h2>ID: 1<br/>')
      expect(response.body).to include('NAME: Pixies<br/>')
      expect(response.body).to include('GENRE: Rock</h2>')
    end
  end

  context "GET /artists/new" do
    it "returns the form to add a new artist" do
      response = get("/artists/new")

      expect(response.status).to eq 200
      expect(response.body).to include('<form method="POST" action="/artists">')
      expect(response.body).to include('<input type="text" name="name"/>')
      expect(response.body).to include('<input type="text" name="genre"/>')
      
    end
  end

  context "POST /artists" do
    it "should validate artist parameters" do
      response = post("/artists", 
        invalid_name_parameter: 'invalid parameter', 
        another_genre_parameter: 'invalid parameter'
      )  

      expect(response.status).to eq(400) 
    end
  end

  context "POST /artists" do
    it "should add 'Wild nothing' to the artists" do
      response = post("/artists", name: 'Wild nothing', genre: 'Indie')
      expect(response.status).to eq 200
      
      response = get("/artists")
      expect(response.body).to include('<a href="/artists/5">Wild nothing</a>')
    end
  end 
end