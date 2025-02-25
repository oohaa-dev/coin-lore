Generell info:
- Apple Swift version 6.0.2
- Xcode 16.1
- Minimum Deployments iOS 18.1
------------------------------------------------------------------------------------------------------------------------

Mappestruktur:
- Jeg har fulgt MVVM-arkitekturen, som skiller mellom Model, ViewModel og View.
    - Models-mappen er ansvarlig for å definere dataene og forretningslogikken.
    - ViewModels håndterer kommunikasjonen mellom Models og Views, og er ansvarlig for å formatere dataene for visning.
    - Filene i Views representerer brukergrensesnittet og UI-komponentene.
        - I Views-mappen finnes også en undermappe kalt Components, hvor jeg har plassert delte og/eller ekstra UI-komponenter som kan gjenbrukes på tvers av ulike visninger.
- API-mappen inneholder Manager-filer som håndterer kommunikasjonen med de forskjellige APIene.
- Jeg har skilt ut delte og/eller ekstra funksjoner i Utilities-mappen for å holde koden ryddig og gjenbrukbar.
- Repositories-mappen er ansvarlig for lagring, hovedsakelig i form av UserDefaults.

------------------------------------------------------------------------------------------------------------------------

User Experience:
    (Relevant kontekst skrevet i parantes)
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
    - Brukeren kan "Pull-To-Refresh" for å oppdatere dataene.

5. StatisticsView:
    - Brukeren ser en tom graf og tre knapper med forskjellig farge "1h", "24" og "7d". De ser også en "+"-knapp.
    - Når de trykker på "+"-knappen, så får de mulighet til å legge til kryptovalutaer i grafen.
        - Inne på denne listen kan brukeren søke på spesifikk kryptovaluta, sortere alfabetisk (a-z/z-a), selektere alle, de-selektere alle og til slutt filtrere listen basert på de kryptovaluta de har valgt, ikke valgt eller se begge deler.
            - (Når brukeren trykker på "done", så lagres de valgte kryptovalutaene i StatisticsRepository til bruk for emoji-animasjon/funksjonalitet senere)
    - Når brukeren har lagt til kryptovalutaer i grafen, så kan de velge om de vil hvilke "change" de ønsker å se: de kan velge å se både 1, 2 og 3 søyler ved å trykke på fargeknappene. Fargene på knappene matcher søylen som representeres i grafen.
        - Grafens verdier (x-akse), justeres automatisk til å passe med den høyeste verdien som representeres.
    - Brukeren kan "Pull-To-Refresh" for å oppdatere dataene.
        
6. SettingsView:
    - Øverst på skjermern får brukeren muligheten til å sette hvilken valuta som skal benyttes i hele appen. De ser også valutakursen av valgt valuta opp imot USD.
        - (Default er dette satt til NOK.)
    - Det neste valget brukeren ser er at de kan velge å lage en custom valuta. Når de aktiverer denne, så blir de tre bokstavene og verdien brukeren skriver inn, satt i hele appen.
        - Når de skrur dette av, går verdien tilbake til den valgte valutaen øverst på siden.
        - /Her har jeg tatt meg frihet til å justere det ene kravet fra eksamen til at dette er en mer generell "custom"-funksjon, heller enn at brukeren kan velge hva NOK skal være. Dette i forlengelse at jeg har lagt til en ekte valutakonverter hvor den faktiske verdien for NOK kan bli satt./
    - Deretter ser brukeren en "Threshold for animation" slider. Verdien som settes her avgjør når en emoji-animasjon skal skje på StatisticsView.
        - (Default er dette satt til 10%. StatisticsViewModel sammenligner nye verdier med de som er lagret i StatisticsRepository og ser om de oversiger prosenten som er lagret i SettingsRepository. Hvis den gjør dette, så starter en emoji-animasjon når brukeren entrer StatisticsView)
    - Til slutt ser brukeren Dark Mode toggle som aktiverer mørk-modus på hele appen.
    
7. (Errorhandling)
    - (Jeg har satt opp en sentralisert errorhandling som gir samme beskjed til brukeren om de ikke lengre har nettverk.)
        
------------------------------------------------------------------------------------------------------------------------

Videre utvikling:
    - Jeg skulle gjerne ryddet enda mer i strukturen i form av å bryte ned enkelte filer til komponenter. Noen filer har noen ganger lik funksjonalietet/UI, noe som kunne blitt gjort om til delte komponenter for.
    - Errorhandling ble satt opp til å fungere opp imot eksamenskravet, men skulle gjerne vært utbedret i form av mer spesifikke errorer som kan forekomme.
    - Det var ikke et krav med bruk av database i denne eksamen, men jeg ville demonstrert dette om det var mer tid til overs med for eksempel at brukeren kunne lagret data om en currency på et gitt tidspunkt og hatt en slags profilside hvor de kunne sett en oversikt dette.
    - Generelt utvikle bedre interaksjonsdesign, herunder samle definerende farger og ikoner i assets.
