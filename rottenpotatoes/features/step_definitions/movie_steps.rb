# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  # I've got busy sqlite exception -> fixed by new test2 db
  Movie.delete_all
  movies_table.hashes.each do |movie|
      Movie.create!(:title => movie[:title], :rating => movie[:rating],
                    :release_date => movie[:release_date])
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
  end
end

Given(/^I check all checkbox$/) do
  Movie.all_ratings.each do |rating|
      step("I check \"ratings_#{rating}\"")
  end
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
    @movies_at_side = []
    all('#movies tr > td:nth-child(1)').each do |movie|
       @movies_at_side << movie.text.to_s 
    end
    
    f1 = @movies_at_side.index(e1)
    f2 = @movies_at_side.index(e2)
    
    if f1.kind_of?(Numeric) and f2.kind_of?(Numeric)
       f1 < f2 
    end
  #  ensure that that e1 occurs before e2.
  #  page.body is the entire content of the page as a string.
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
    rating_list.split(', ').each do |rating|
        if uncheck
           step("I uncheck \"ratings_#{rating}\"")  
        else
           step("I check \"ratings_#{rating}\"")
       end
    end
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
end

Then /I should see all the movies/ do
    @movies_at_side = []
    all('#movies tr > td:nth-child(1)').each do |movie|
       @movies_at_side << movie.text.to_s
    end
    
    Movie.all.each do |movie|
       @movies_at_side.should include movie[:title].to_s 
    end
  # Make sure that all the movies in the app are visible in the table
end

Then(/^I should see movies with rating (.*)$/) do |rating_list|
  all('#movies tr > td:nth-child(2)').each do |td|
    rating_list.should include td.text
  end
end

Then(/^I should not see movies with rating (.*)$/) do |rating_list|
  all('#movies tr > td:nth-child(2)').each do |td|
    not rating_list.include? td.text
  end
end