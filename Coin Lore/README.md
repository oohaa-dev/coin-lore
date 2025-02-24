
User Experience:
    (Relevant backend skrevet i parantes)
    /Metakommentar skrevet i skråstrek/

1. Brukeren trykker på appicon og SplashView åpner seg.
2. SplashView:
    - Viser en kort animasjon før brukeren fraktes til TabsView
        - (TabsView består av 4 skjermer: MainView, MarketView, StatisticsView og SettingsView. Brukeren blir default fraktet til MainView)
        
3. MainView:
    - Brukeren ser en oversikt over relevant data hentet fra "https://api.coinlore.net/api/global/". Etter 5 sekunder blir datateksten rød for å indikere at den ikke er oppdatert.
        - Brukeren kan da trykke på "RefreshButton" som henter oppdatert data og setter skriften tilbake til normal farge.
            - /Tiden for rød skrift er satt lavt for enkel testing av/verifisering av kode.
            - /NB! Jeg valgte å bruke RefreshButton og ikke Pull-To-Refresh på denne skjermen da jeg opplevde utfordringer når jeg mikset "GeometryReader" og "Scrollview". Ønsket å bruke "GeometryReader" på denne skjermen for bedre design da det ikke var så mange datapunkter å vise./
                - /Demonstrerer bruk av Pull-To-Refresh på MarketView og StatisticsView istedenfor MainView./
                
4. MarketView:
    - Brukeren ser en liste med alle currencies som er hentet fra "https://api.coinlore.net/api/tickers/".
        - Hver currency vises med title, price_usd og percent_change_24h.
            - (price_usd blir default konvertert til NOK av en ekstra currency exchange API: "https://api.freecurrencyapi.com/v1/latest")
    - Brukeren kan sortere listen basert på rank, percent_change_1h, percent_change_24h, percent_change_7d og om denne sorteringen skal være stingende eller synkende.
    - Brukeren kan også søke på spesfikk title i søkefeltet øverst på skjermen.
        - (Dette kombineres med sorteringen brukeren har valgt)
    - Brukeren kan trykke på en kryptovaluta og bli ført til DetailsView.
        - DetailsView viser detaljert informasjon med samme design som på MainView.
            - Her er det også lagt inn timer på 5sekund som gjør skriften rød om den ikke er oppdatert på 5sek og en "RefreshButton".

5. StatisticsView:
    - Brukeren ser en tom graf og tre knapper med forskjellig farge "1h", "24" og "7d". De ser også en "+"-knapp.
    - Når de trykker på +-knappen, så får de mulighet til å legge til kryptovalutaer de ønsker å se i grafen.
        - Inne på denne listen kan brukeren søke på spesifikk kryptovaluta, sortere alfabetisk (a-z/z-a), selektere alle, de-selektere alle og til slutt filtrere listen basert på de kryptovaluta de har valgt, ikke valgt eller se begge deler.
            - (Når brukeren trykker på "done", så lagres de valgte kryptovalutaene i StatisticsRepository til bruk for emoji-animasjon/funksjonalitet senere)
    - Når brukeren har lagt til kryptovalutaer i grafen, så kan de velge om de vil hvilke "change" de ønsker å se: de kan velge å se både 1, 2 og 3 søyler ved å trykke på fargeknappene. Fargene på knappene matcher søylen som representeres i grafen.
        - Grafens verdier (x-akse), justeres automatisk til å passe med den høyeste verdien som representeres.
        
6. SettingsView:
    - Øverst her får brukeren muligheten til å sette hvilken valuta som skal benyttes i hele appen. De ser også valutakursen av valgt valuta opp imot USD.
        - Defaut er dette satt til NOK
    - Det neste valget brukeren ser er at de kan velge å lage en custom valuta. Når de aktiverer denne, så blir de tre bokstavene og verdien brukeren skriver inn, satt som valuta og verdi i hele appen.
        - Når de skrur dette av, går verdien tilbake til den valgte valutaen øverst på siden.
        - /Her har jeg tatt meg frihet til å justere det ene kravet fra eksamen til at dette er en mer generell "custom"-funksjon, heller enn at brukeren kan velge hva NOK skal være./
    - Deretter ser brukeren en "Threshold for animation" slider. Verdien som settes her avgjør når en emoji-animasjon skal skje på StatisticsView.
        - (Default er dette satt til 10%. StatisticsViewModel sammenligner nye verdier med de som er lagret i StatisticsRepository og ser om de oversiger prosenten som er satt her i SettingsView. Hvis den gjør dette, så starter en emoji-animasjon når brukeren entrer StatisticsView)
    - Til slutt ser brukeren Dark Mode toggle som aktiverer mørk-modus i over hele appen.
    
7. Errorhandling
    - Jeg har satt opp en sentralisert errorhandling som gir samme beskjed til brukeren om de ikke lengre har nettverk.
        
        
