if (do shell script "defaults read com.apple.finder CreateDesktop") is equal to "1" then
    do shell script "defaults write com.apple.finder CreateDesktop -bool false"
else
    do shell script "defaults write com.apple.finder CreateDesktop -bool true"
end if

do shell script "killall Finder"

return 1
