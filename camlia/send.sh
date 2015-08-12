API_TOKEN="uleu4Egefit+lvQ/V7uc7GKtn7a/404UiQ6wg5lewu4="
TEAM_ID=17
curl --user :$API_TOKEN -X POST -H "Content-Type: application/json" \
        -d @$1 \
        https://davar.icfpcontest.org/teams/$TEAM_ID/solutions
