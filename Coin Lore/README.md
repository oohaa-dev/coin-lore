
User Experience:
    (Relevant backend skrevet i parantes)
    /Metakommentar skrevet i skråstrek/

- Brukeren trykker på appicon og SplashView åpner seg.
- SplashView:
    - Viser en kort animasjon før brukeren fraktes til TabsView
        - (TabsView består av 4 skjermer: MainView, MarketView, StatisticsView og SettingsView. Brukeren blir default fraktet til MainView)
- MainView:
    - Brukeren ser en oversikt over relevant data hentet fra "https://api.coinlore.net/api/global/". Etter 5 sekunder blir datateksten rød for å indikere at den ikke er oppdatert.
        - Brukeren kan da trykke på "RefreshButton" som henter oppdatert data og setter skriften tilbake til normal farge.
            - /Tiden for rød skrift er satt lavt for enkel testing av/verifisering av kode.
            - /Jeg valgte å bruke RefreshButton og ikke Pull-To-Refresh på denne skjermen da jeg opplevde utfordringer når jeg mikset "GeometryReader" og "Scrollview"./
                - /Ønsket å bruke "GeometryReader" på denne skjermen for bedre design./
                - /Demonstrerer at jeg mestrer Pull-To-Refresh på MarketView og StatisticsView istedenfor MainView./
                
- MarketView:
    - Brukeren ser en liste med alle currencies som er hentet fra "https://api.coinlore.net/api/tickers/".
        - Hver currency vises med title, price_usd og percent_change_24h.
            - (price_usd blir default konvertert til NOK av en ekstra currency exchange API: "https://api.freecurrencyapi.com/v1/latest")
    - Brukeren kan sortere listen basert på rank, percent_change_1h, percent_change_24h, percent_change_7d og om denne sorteringen skal være stingende eller synkende.
    - Brukeren kan også søke på spesfikk title i søkefeltet øverst på skjermen.
        - (Dette kombineres med sorteringen brukeren har valgt)
    - Brukeren kan trykke på en kryptovaluta og bli ført til DetailsView.
        - DetailsView viser mer detaljert: symbol, 
        
