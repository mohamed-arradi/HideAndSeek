if (do shell script "defaults read com.apple.finder CreateDesktop") is false then
    return 0
else
    return 1
end if
