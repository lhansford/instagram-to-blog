# Fetch images/vids
instagram-scraper $INSTAGRAM_USERNAME --latest-stamps ~/Dropbox/Inbox/Instagram/history.log --media-metadata -u $INSTAGRAM_USERNAME -p $INSTAGRAM_PASSWORD -d ~/Dropbox/Inbox/Instagram -T {year}-{month}-{day}_{urlname} -i
ruby main.rb
rm instagram-scraper.log
git -C /Users/luke/Documents/development/lukehansford.me add .
git -C /Users/luke/Documents/development/lukehansford.me commit -am "Updated instagram posts"
git -C /Users/luke/Documents/development/lukehansford.me push
sh /Users/luke/Documents/development/lukehansford.me/update-remote.sh