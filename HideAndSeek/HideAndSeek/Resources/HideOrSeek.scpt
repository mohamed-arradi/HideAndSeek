if (do shell script "defaults read com.apple.finder CreateDesktop") is false then
   do shell script "defaults write com.apple.finder CreateDesktop true"
else
   do shell script "defaults write com.apple.finder CreateDesktop false"
end if
