# Fetch images/vids
instaloader $INSTAGRAM_USERNAME --fast-update --dirname-pattern  ~/Dropbox/Images/Instagram --filename-pattern="{date_utc:%Y-%m-%d}-{mediaid}"  --no-metadata-json  --post-metadata-txt="{shortcode}|{date_utc:%Y-%m-%d %H:%M}|{caption}"  --no-profile-pic

ruby main.rb
git -C /Users/luke/Documents/development/lukehansford.me add .
git -C /Users/luke/Documents/development/lukehansford.me commit -am "Updated instagram posts"
git -C /Users/luke/Documents/development/lukehansford.me push
sh /Users/luke/Documents/development/lukehansford.me/update-remote.sh
