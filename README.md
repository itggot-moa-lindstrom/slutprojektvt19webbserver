# Projektplan

## 1. Projektbeskrivning
Mitt projekt är en webbsida där man kan lägga upp och gilla inlägg. Har man skapat inlägget själv kan man redigera dem. Man har också en profilsida med användarinformation som man kan redigera. Är man inloggad kan man skapa och gilla inlägg, men som gäst kan man endast läsa andras inlägg. Man kan endast gilla en post en gång.

## 2. Vyer (sidor)
Startsida: Här väljer man om man vill logga in, skapa en ny användare eller vara gäst på hemsidan.

/signup: Här skriver man in sin användarinformation för att registrera sig som en ny användare.

/myside: Detta är användarens profilsida. Här ser man sin användarinformation och sina inlägg och man kan välja mellan att redigera sin information, redigera inlägg, gå till /posts för att se allas inlägg och att logga ut.

/myside/edit: Här redigerar man sin användarinformation.

/posts: Allas posts ligger här. Är man inloggad kan man gilla andras inlägg eller skapa ett nytt. Härifrån kan man också ta sig tillbaka till sin profil om man är inloggad. Är man inne på denna sidan som gäst kan man endast läsa de andras inlägg.

/newpost: Hit kommer man om man väljer att skapa ett inlägg. Man kan komma hit genom /myside eller /posts. Man skriver in titel och text och lägger upp det på hemsidan för alla att se.

Sen finns det några sidor med felmeddelanden. Jag har en som kommer upp om man försöker gilla eller skapa ett inlägg utan att vara inloggad, ett som säger till att någonting gick snett och ett som kommer upp om man försöker gilla ett inlägg två gånger med samma konto.

## 3. Funktionalitet (med sekvensdiagram)
Hemsidan är ett forum som genom en databas i SQL sparar all information som skrivs in och ändras. Sidan fungerar med hjälp av controller, model, slim-filer, samt databasen.

Sekvensdiagram: https://bit.ly/2WpKd2C

## 4. Arkitektur (Beskriv filer och mappar)
I min slutprojekt-mapp finns .vscode, .yarddoc, db, doc, public, views, .byebug_history, controller.rb, Gemfile, Gemfile.lock, model.rb och README.md.

I mappen db ligger databasen och här är all data samlad.

I mappen views ligger alla slim-filer.

I controller och model ligger den mesta koden. Jag har delat upp koden i dessa två filer för att göra den enklare att läsa och förstå. I model finns funktionerna med koppling till databasen och dessa funktioner har jag kallat på i controller. I controller ligger även alla sessions och redirects. Koden är strukturerad i ordningen jag skrev den och jag har valt att ha kvar denna struktur för att jag anser att det gör koden enklare att förstå. Detta eftersom jag började skriva det man först kommer in på på hemsidan och fortsatt på detta vis genom hela projektet. Koden ligger alltså i den ordningen man kommer använda den på den på hemsidan.

## 5. (Databas med ER-diagram)
https://www.draw.io/?title=Copy%20of%20SlutprojDB.drawio&client=1
