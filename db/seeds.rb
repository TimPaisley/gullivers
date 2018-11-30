# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create!(email: "dev@gullivers.guide", password: "swordfish", password_confirmation: "swordfish")

southernWalkwayLocations =
    [
        Location.create!(geometry: "POINT(174.798531 -41.288610)", name: "Oriental Parade", description: "From the Oriental Parade entrance, the walkway zigzags up the hill. Several paths intersect the first section of the walkway, however, the Southern Walkway route itself is clearly marked with posts bearing directional arrows.
        
        Seats strategically placed on the hillside offer a place to rest and enjoy the view of one of New Zealand's most picturesque harbours. You can also look out over Oriental Parade, which is lined with restored turn-of-the-century houses and modern apartments."),
        
        Location.create!(geometry: "POINT(174.793469 -41.296599)" , name: "Mt Victoria Summit", description: "Here at a height of 196 metres, there are sweeping views of the city, harbour and Tinakori Hill, the Hutt Valley and eastern harbour bays, Matiu/Somes Island and the Miramar Peninsula.
        
        The Byrd Memorial honours the memory of Admiral Richard E. Byrd, a polar aviation explorer who mapped large areas of Antarctica and identified closely with New Zealand's polar explorers."),
        
        Location.create!(geometry: "POINT(174.788873 -41.319925)", name: "Truby King Park", description: "Sir Truby King planned, designed and personally supervised the development of the garden which cost thousands of points. It included roading, paths, wind breaks, a tennis court and extensive brick garden walls.
        
        Sir Truby King is best known as the founder in 1907 of the Plunket Society which promoted his beliefs surrounding infant welfare. When Sir Truby King died in 1938 he was given a state funeral and buried in the grounds of his Melrose property."),
        
        Location.create!(geometry: "POINT(174.784308 -41.323929)", name: "Wellington Zoo", description: "Wellington Zoo was founded in April 1906 when the Bostok and Wombwell Circus presented a young lion to Wellington City. The lion, named 'King Dick', after Prime Minister Richard Seddon who had died that year, was initially housed at the Botanic Gardens along with a small collection of animals.
        
        As you walk past, you can see the Hamadryas Baboon enclosure. The Hamadryas was the sacred baboon of the ancient Egyptians, and was often pictures on temples and monolisths as the attendant or representative of Thoth, the god of letters. Baboons were mummified, entombed and associated with sun worship."),
        
        Location.create!(geometry: "POINT(174.785053 -41.342290)", name: "Houghton Bay", description: "Houghton Bay is just around the corner from sheltered Princess Bay, but is exposed to big southerly swells that can cause a dangerous undertow.  Unlike Princess Bay, it can be unsafe for swimming. Surfers can sometimes be seen when conditions are good.
        
        Houghton Bay is the first point where the Southern Walkway meets the coast. It is a short walk up Houghton Valley Road to Sinclair Park, where a track leads up to Buckley Road and outstanding views. There is also a track on the right side of the road that leads to View Road Park and the Te Ranga a Hiwi Track."),

        Location.create!(geometry: "POINT(174.770805 -41.343425)", name: "Shorlan Park", description: "Opened in February 1930, the eight-sided memorial rotunda at Island Bay was built at the end of the tram and bus line from the city. The memorial, unlike other cenotaphs, was built as a tribute from the residents to the 106 soldiers who enlisted from the district during the First World War.")
    ]


Adventure.create!(name: "Southern Walkway", image: "http://farm3.static.flickr.com/2652/3956961061_0fffc5a9c4.jpg", description: "The Southern Walkway is an 11km walk along the Town Belt between Oriental Bay and Island Bay. The total walk can be completed in 4–5 hours depending on fitness. Although the walk is steep in places, it is not difficult overall and is suitable for those of average fitness.", locations: southernWalkwayLocations, badge_url: "", difficulty: "3", wheelchair_accessible: false)

Adventure.create!(name: "City to Sea Walkway", image: "http://farm3.static.flickr.com/2535/3866323429_b0d08ac097.jpg", description: "The City to Sea Walkway starts in the heart of central Wellington near Parliament and ends at the south coast, 12km away in Island Bay. The walk takes about 6−7 hours but can be done in stages. To complete the entire walk in 1 day you will need a good level of fitness.", locations: southernWalkwayLocations, badge_url: "", difficulty: "4", wheelchair_accessible: false)

Adventure.create!(name: "Botanic Gardens", image: "https://www.rydges.com/accommodation/new-zealand/wellington/wp-content/uploads/sites/41/2015/10/960x330_Wellington-Botanic-Gardens-465x330.jpg", description: "Choose between two walks: The 2.4 km Lookout Loop Walk, taking about 1.5 hours or the 1.0 km Salvation Bush Walk, taking about 45 minutes.", locations: southernWalkwayLocations, badge_url: "", difficulty: "1", wheelchair_accessible: true)

Adventure.create!(name: "Wellington Beaches", image: "https://static2.stuff.co.nz/1357637894/993/8155993.jpg", description: "The Wellington City Council have installed a new type of walking experience on Mount Victoria that promotes time spent engaging in the natural environment and encourages families to explore our amazing outdoors.", locations: southernWalkwayLocations, badge_url: "", difficulty: "1", wheelchair_accessible: false)

Adventure.create!(name: "Heritage Week 2018", image: "https://services1.arcgis.com/CPYspmTk3abe6d7i/arcgis/rest/services/Heritage_week_virtual_tour/FeatureServer/0/13/attachments/27", description: "Wellington Heritage Week is back for its second year, once again showcasing the history of the city with events, tours, exhibitions, and sneak peeks behind the scenes of some hidden treasures.", locations: southernWalkwayLocations, badge_url: "", difficulty: "2", wheelchair_accessible: true)
