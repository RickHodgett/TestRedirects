require 'selenium-webdriver'
require 'csv'
require 'chromedriver/helper'
require 'colorize'

=begin
 This tool's purpose is to read a clients redirect csv file and test that the old urls are redirecting to the new urls.
Currently this tools requires the csv file to contain two columns with the old urls in the first column and the new urls
in the second column. The first row of the file is reserved for headers. If there are no headers in the file, please add
them in. As the urls are being checked, the results are printed in the console. Any failures are also exported into a
new "Failed redirects" csv file. Currently this csv does not contain headers. Please check the below comments for
additional detail for what each section does.
=end
class Redirects
  driver = Selenium::WebDriver::Driver.for :firefox
  url_hash = {}
  csv_array = []
  row_counter = 2

=begin
This section reads the redirects csv and places information for each row into an array.
Since both the 'to url' and the 'from url' are contained within the same row, they both are contained
in the value of each array value. You will need to either update the path and/or csv name to what you want or edit the
csv itself with your new redirects. Currently the tool is checking for the csv in the same directory as the tool files.
=end

  CSV.foreach('Redirects.csv', headers: true) { |row| csv_array << row.to_s}

=begin
This section iterates through the csv array and splits the "from url" and "to url" into a new array
so each url is associated to its own key then that the values are associated from the new array to a new hash.
In the hash the from url is the key and the to url is the value.
=end

  csv_array.each { |word|
    @my_word = word.split(',')
    url_hash[@my_word[0]] = @my_word[1]}

=begin
In this section the driver is directed to the 'from_url'. If the redirect is in place by the developer than
the redirect will initiate automatically and direct the driver to the 'to_url'. The 'redirected_to' variable grabs
the current url which should be the where the driver was redirected to. We then compare that 'redirected_to' url to
the 'to_url' from the redirects spreadsheet. If it's a pass then the result prints out
the 'from_url' and to_url and marks it as a Pass. If it does not match, we print the 'from_url' and 'to_url' and the
'redirected_url' and we mark it as a fail. All fails are captured into a new csv. You should go into the code and
name the new csv to something relevant to the project. After the run is complete the driver quits.
=end

  url_hash.each { |from_url, to_url|
    driver.navigate.to from_url
    redirected_to = driver.current_url.to_s.downcase
    from_actual = from_url.to_s.downcase.strip
    to_actual = to_url.to_s.downcase.strip
    if redirected_to == to_actual
      puts "ROW #{row_counter}: PASS ".green + from_actual + ' >>> '.green + to_actual
    else
      puts "ROW #{row_counter}: Fail ".red + from_actual + ' >>> '.red + to_actual + ' Redirected to '.red + redirected_to
      CSV.open('RedirectFails.csv', 'a') { |csv| csv << [from_actual, to_actual, redirected_to]}
    end
    row_counter += 1
  }
  driver.quit
rescue StandardError => e
  puts e
end