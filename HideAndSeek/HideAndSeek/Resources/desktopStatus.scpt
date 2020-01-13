if (do shell script "defaults read com.apple.finder CreateDesktop") is equal to "1" then
    return 1
else
    return 0
end if
