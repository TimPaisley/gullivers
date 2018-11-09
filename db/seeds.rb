# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create!(email: "dev@gullivers.guide", password: "swordfish", password_confirmation: "swordfish")

Location.create!(geometry: "POINT(174.722247 -41.296912)", name: "Makara Peak", description: "If you're a biker then chances are you're already familiar with the world-class Makara Peak Mountain Bike Park. It features a 40-kilometre network of tracks, and the 4WD track is suitable for walking.", image_url: "https://upload.wikimedia.org/wikipedia/commons/2/22/Makara_Peak_Mountain_Bike_Park.JPG", reward: 10)

Location.create!(geometry: "POINT(174.738499 -41.295575)" , name: "Wrights Hill", description: "Best known for its extensive WWII fortifications, the reserve also features a bike and walking track.", image_url: "https://farm2.static.flickr.com/1687/24219270232_0038ec3f10_b.jpg", reward: 15)

Location.create!(geometry: "POINT(174.783376 -41.233171)", name: "Mount Kaukau", description: "Mount Kaukau is the most visible high point in the city's landscape. It is part of the Northern Walkway.", image_url: "https://upload.wikimedia.org/wikipedia/commons/f/f9/Makara_and_South_Island_from_Mt_Kaukau_-_Flickr_-_111_Emergency.jpg", reward: 12)

Location.create!(geometry: "POINT(174.740672 -41.277445)", name: "Johnston Hill", description: "This reserve has been a public recreation domain since 1942. Bush remnants here form part of the most significant native ecosystems in the Outer Green Belt.", image_url: "https://wellington.govt.nz/~/media/recreation/parks-and-reserves/images/johnston-hill-content.jpg?mw=320&mh=320", reward: 10)

Location.create!(geometry: "POINT(174.895808 -41.105681)", name: "The Crowsnest", description: "Kilmister Tops are part of the main ridgeline that runs above Otari-Wilton’s Bush through to Johnston Hill. This high, broad area is mostly open pasture and an attractive contrast to the dense bush on the eastern slopes and valleys below. The area is now part of the Skyline Walkway and is used for walking, running and mountain biking.", image_url: "", reward: 15)


Adventure.create!(name: "Southern Walkway", description: "The Southern Walkway is an 11km walk along the Town Belt between Oriental Bay and Island Bay. The total walk can be completed in 4–5 hours depending on fitness. Although the walk is steep in places, it is not difficult overall and is suitable for those of average fitness.", badge_url: "", difficulty: "3", wheelchair_accessible: false)

Adventure.create!(name: "City to Sea Walkway", description: "The City to Sea Walkway starts in the heart of central Wellington near Parliament and ends at the south coast, 12km away in Island Bay. The walk takes about 6−7 hours but can be done in stages. To complete the entire walk in 1 day you will need a good level of fitness.", badge_url: "", difficulty: "4", wheelchair_accessible: false)

Adventure.create!(name: "Wrights Hill Loops", description: "Choose between two walks: The 2.4 km Lookout Loop Walk, taking about 1.5 hours or the 1.0 km Salvation Bush Walk, taking about 45 minutes.", badge_url: "", difficulty: "2", wheelchair_accessible: true)

Adventure.create!(name: "Matairangi Nature Trail", description: "The Wellington City Council have installed a new type of walking experience on Mount Victoria that promotes time spent engaging in the natural environment and encourages families to explore our amazing outdoors.", badge_url: "", difficulty: "1", wheelchair_accessible: false)

Adventure.create!(name: "Brooklyn Turbine Trail", description: "Explore regenerating bush in Polhill Reserve and take in the best views of the city. This route is popular with mountain bikers, runners – and a healthy spillover of native birds from the nearby Zealandia sanctuary. ", badge_url: "", difficulty: "2", wheelchair_accessible: true)