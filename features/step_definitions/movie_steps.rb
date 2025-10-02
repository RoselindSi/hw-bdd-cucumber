# features/step_definitions/movie_steps.rb

# ------------------------------------------------------------
# Add a declarative step here for populating the DB with movies.
# ------------------------------------------------------------
Given(/the following movies exist/) do |movies_table|
  # Keep scenarios isolated: start from a clean DB (for Movies).
  # Background runs before each scenario. Without this, rows would
  # accumulate across scenarios and "n seed movies should exist" would fail.
  Movie.delete_all

  # movies_table.hashes => Array of Hashes, e.g.
  # { "title" => "Alien", "rating" => "R", "release_date" => "1979-05-25" }
  movies_table.hashes.each do |row|
    Movie.create!(row)  # raise on invalid input (helps catch typos early)
  end

  # Optional debug to Cucumber log
  log "Seeded #{Movie.count} movies: #{Movie.pluck(:title).join(', ')}"
end

Then(/(.*) seed movies should exist/) do |n_seeds|
  expect(Movie.count).to eq n_seeds.to_i
end

# ------------------------------------------------------------
# Make sure that one string (regexp) occurs before or after another one
# on the same page (specifically within the movie list table).
# ------------------------------------------------------------
Then(/^I should see "(.*)" before "(.*)" in the movie list$/) do |e1, e2|
  # Narrow the search to the movies table to avoid false positives
  # from other parts of the page.
  within('table#movies') do
    body_text = page.text
    i1 = body_text.index(e1)
    i2 = body_text.index(e2)
    expect(i1).not_to be_nil, %(Expected to find "#{e1}" in the movie list)
    expect(i2).not_to be_nil, %(Expected to find "#{e2}" in the movie list)
    expect(i1).to be < i2, %(Expected "#{e1}" to appear before "#{e2}" in the movie list)
  end
end

# ------------------------------------------------------------
# Make it easier to express checking several boxes at once:
#   When I check the following ratings: PG, G, R
# ------------------------------------------------------------
When(/I check the following ratings: (.*)/) do |rating_list|
  ratings = rating_list.split(/\s*,\s*/).reject(&:blank?)
  ratings.each do |r|
    # IDs are "ratings_G", "ratings_PG", etc. This matches canonical views.
    step %Q{I check "ratings_#{r}"}
  end
end


When(/I uncheck the following ratings: (.*)/) do |rating_list|
  rating_list.split(/\s*,\s*/).each do |r|
    step %Q{I uncheck "ratings_#{r}"}
  end
end
# ------------------------------------------------------------
# Verify presence/absence of a set of movie titles on the page.
# Example:
#   Then I should see the following movies: Alien, Up
#   Then I should not see the following movies: Toy Story, Jaws
# ------------------------------------------------------------
Then(/^I should (not )?see the following movies: (.*)$/) do |no, movie_list|
  titles = movie_list.split(/\s*,\s*/).reject(&:blank?)
  within('table#movies, #movies') do
    titles.each do |title|
      if no
        expect(page).not_to have_text(title)
      else
        expect(page).to have_text(title)
      end
    end
  end
end

# ------------------------------------------------------------
# Ensure all movies in the DB are visible in the table.
# This assumes one <tr> per movie in <table id="movies"> <tbody>.
# ------------------------------------------------------------
Then(/^I should see all the movies$/) do
  within('table#movies tbody') do
    rows = all('tr').size
    expect(rows).to eq(Movie.count),
      "Expected #{Movie.count} rows in the movies table, found #{rows}"
  end
end

### Utility Steps Just for this assignment.

Then(/^debug$/) do
  # Use this to write "Then debug" in your scenario to open a console.
  require "byebug"
  byebug
  1 # intentionally force debugger context in this method
end

Then(/^debug javascript$/) do
  # Use this to write "Then debug" in your scenario to open a JS console
  page.driver.debugger
  1
end

Then(/complete the rest of of this scenario/) do
  # This shows you what a basic cucumber scenario looks like.
  # You should leave this block inside movie_steps, but replace
  # the line in your scenarios with the appropriate steps.
  raise "Remove this step from your .feature files"
end

Then('the {string} should be highlighted') do |header_id|
  th = find("##{header_id}")
  # Ensure the class attribute contains 'hilite'
  classes = th[:class].to_s.split(/\s+/)
  expect(classes).to include('hilite'), %(Expected ##{header_id} to have class "hilite", got "#{th[:class]}")
end

# Allow a generic order assertion without scoping phrase:
#   Then I should see "Aladdin" before "Amelie"
# If the movies table exists, scope to it; otherwise use the whole page text.
Then(/^I should see "(.*)" before "(.*)"$/) do |e1, e2|
  text_source =
    if page.has_css?('table#movies')
      find('table#movies').text
    else
      page.text
    end

  i1 = text_source.index(e1)
  i2 = text_source.index(e2)

  expect(i1).not_to be_nil, %(Expected to find "#{e1}" on the page)
  expect(i2).not_to be_nil, %(Expected to find "#{e2}" on the page)
  expect(i1).to be < i2, %(Expected "#{e1}" to appear before "#{e2}")
end
