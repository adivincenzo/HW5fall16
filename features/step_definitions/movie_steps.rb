# Completed step definitions for basic features: AddMovie, ViewDetails, EditMovie 

Given (/^I am on the RottenPotatoes home page$/) do
  visit movies_path
 end


 When (/^I have added a movie with title "(.*?)" and rating "(.*?)"$/) do |title, rating|
  visit new_movie_path
  fill_in 'Title', :with => title
  select rating, :from => 'Rating'
  click_button 'Save Changes'
 end

 Then (/^I should see a movie list entry with title "(.*?)" and rating "(.*?)"$/) do |title, rating| 
   result=false
   all("tr").each do |tr|
     if tr.has_content?(title) && tr.has_content?(rating)
       result = true
       break
     end
   end  
  expect(result).to be_truthy
 end

 When (/^I have visited the Details about "(.*?)" page$/) do |title|
   visit movies_path
   click_on "More about #{title}"
 end

 Then (/^(?:|I )should see "([^"]*)"$/) do |text|
    expect(page).to have_content(text)
 end

 When (/^I have edited the movie "(.*?)" to change the rating to "(.*?)"$/) do |movie, rating|
  click_on "Edit"
  select rating, :from => 'Rating'
  click_button 'Update Movie Info'
 end


# New step definitions to be completed for HW5. 
# Note that you may need to add additional step definitions beyond these


# Add a declarative step here for populating the DB with movies.

Given (/the following movies have been added to RottenPotatoes:/) do |movies_table|

  movies_table.hashes.each do |movie|
    # Each returned movie will be a hash representing one row of the movies_table
    # The keys will be the table headers and the values will be the row contents.
    # Entries can be directly to the database with ActiveRecord methods
    # Add the necessary Active Record call(s) to populate the database.
    if ! Movie.find_by_title(movie[:title]) 
        Movie.create!(movie)
    end
  
  end
end

When (/^I have opted to see movies rated: "(.*?)"$/) do |arg1|
  # HINT: use String#split to split up the rating_list, then
  # iterate over the ratings and check/uncheck the ratings
  # using the appropriate Capybara command(s)
  ratings = "G,PG,PG-13,NC-17,R".split(",")
  ratings.each do |rating|
      uncheck "ratings\[#{rating}\]"
  end
  arg1.split(', ').each do |rating|
    check "ratings\[#{rating}\]"
  end 
  click_on 'Refresh'
      
end

Then (/^I should see only movies rated: "(.*?)"$/) do |arg1|
  ratings = "G,PG,PG-13,NC-17,R".split(",")
  arg1.split(',').each do |rating|
    page.has_checked_field? "ratings\[#{rating}\]"
    ratings.delete(rating)
  end
  ratings.each do |rating|
    page.has_unchecked_field? "ratings\[#{rating}\]"
  end
  
end

Then (/^I should see all of the movies$/) do
  size = Movie.all.size
  size.should == ((page.all('table#movies tr').count)-1)
end

When(/^I filter on Movie Title$/) do
  click_link("title_header")
end

Then(/^I should see "(.*?)" before "(.*?)"$/) do |arg1, arg2|
  rows = all('tr/td[1]')
  result = true
  rows.each_with_index do |row, index|
      if(index + 1 < rows.count)
         if(rows[index].text.casecmp(rows[index+1].text) == 1)
            result = false
            break
          end
      end
  end
  expect(result).to be_truthy
end

When(/^I filter on Release Date$/) do
  click_link("release_date_header")
end

Then(/^I should see movies filtered by Release Date$/) do
  num = 0
  list = []
  within_table('movies') do
    within(:xpath, 'tbody') do
      num = all('tr').count
      all("tr").each do |tr|
        list << tr.find("td[#{3}]").text
      end
    end
  end
  result = false
  if (list == list.sort && num == Movie.count)
    result = true
  end
  expect(result).to be_truthy
end