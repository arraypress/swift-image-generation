//
//  StyleText+Travel.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  Places. Cities and landscapes by name; no venues, brands or events.
//  Written for this library; the format is described in StyleCatalog.swift.
//

extension StyleText {

    static let travel = """
    ## paris | Paris | travel
    look: travel photograph, romantic and cinematic
    camera: 35mm lens, the city around the subject
    light: soft spring daylight
    wear: a Breton striped top, a trench coat and loafers
    - at a pavement café with a croissant and an espresso | who: {subject} looking out at the street
    - on a stone bridge over the Seine at sunset | light: golden low sun on the river
    - on a cobbled Montmartre street of steep steps | camera: 50mm lens, full figure
    - at a bookstall along the river, leafing through old prints | light: dappled plane-tree shade
    - on a Haussmann balcony with wrought-iron railings | light: morning light across the rooftops
    - in a covered passage with a glass roof and mosaic floor | light: soft filtered skylight
    - on a rooftop terrace at night with the city lit up | wear: an elegant black evening outfit | light: city lights and dusk

    ## tokyo | Tokyo | travel
    look: travel photograph, vivid and atmospheric
    camera: 35mm lens, street-level
    light: city light
    wear: a sleek oversized coat and wide trousers
    - at a busy pedestrian crossing at night, crowds blurred | light: giant screens and neon
    - in a narrow lantern-lit alley of tiny bars | light: red paper lanterns
    - under cherry blossoms along a canal | light: soft pink spring daylight
    - at a quiet shrine with vermilion gates | light: dappled forest light
    - on a train platform as a train arrives | camera: slow shutter, the train a streak
    - at a ramen counter with steam rising | light: warm overhead lamps
    - on a rooftop above the bay at night | light: the bay bridge and towers glittering

    ## greek-islands | Greek islands | travel
    look: sun-drenched travel photograph, blue and white
    camera: 35mm lens
    light: bright Aegean sun
    wear: flowing white linen and sandals
    - on a whitewashed staircase with a blue door | who: {subject} pausing on the steps
    - at a cliffside table above the caldera at sunset | light: pink and orange sunset | wear: an elegant white evening outfit with gold jewellery
    - by a pool carved into the cliff | camera: 24mm lens, the sea below
    - in a narrow lane draped with bougainvillea | light: bright shade and magenta flowers
    - on a small boat in a turquoise cove | wear: swimwear under a loose shirt and sunglasses
    - dancing at an open-air beach club at night | light: coloured DJ lights and a full moon | wear: a sequinned top and white trousers
    - at a seafront taverna with grilled fish and ouzo | light: warm evening light

    ## bali | Bali | travel
    look: tropical travel photograph, lush and serene
    camera: 35mm lens
    light: warm tropical light
    wear: a breezy linen set and a woven hat
    - at the edge of terraced rice fields at sunrise | light: misty golden sunrise
    - lounging beside an infinity pool facing the jungle | wear: swimwear under an open linen shirt
    - on a giant jungle swing over a valley | camera: 24mm lens, wide
    - at a temple gate with stone carvings | light: soft overcast
    - with a floating breakfast tray in a villa pool | camera: high angle
    - at a beach bar at sunset with surfboards nearby | light: golden sunset

    ## desert-city-nights | Desert city nights | travel
    look: glamorous night travel photograph, glittering and bold
    camera: 35mm lens
    light: neon and casino-sign glow
    wear: a sparkling evening outfit / a sparkling mini dress and heels / a sharp velvet blazer and open shirt
    - on a boulevard of giant illuminated signs at night | who: {subject} spinning around, laughing
    - by a fountain show at night | light: water lit gold and white
    - at a rooftop pool party at sunset | wear: resort wear and sunglasses | light: hot orange sunset
    - in a vintage diner off the strip at 3 a.m. | light: buzzing fluorescent light
    - on a desert highway beside a classic convertible | light: hot afternoon sun | wear: a denim jacket and sunglasses
    - in a hotel suite with a wall of windows over the lights | light: city glow

    ## digital-nomad | Digital nomad | travel
    look: candid travel lifestyle photograph
    camera: 35mm lens
    light: natural light
    wear: a relaxed linen shirt with a canvas backpack
    - working on a laptop at a beach café in Lisbon | light: bright Atlantic light
    - on a canal bridge in Amsterdam with bicycles behind | light: soft grey daylight
    - in a Mexico City co-working space with plants | light: warm window light
    - at a tram stop in Melbourne with a coffee | light: morning sun
    - on a scooter in the old quarter of Hanoi | camera: 50mm lens, motion blur
    - at a hostel rooftop in Cape Town, Table Mountain behind | light: late afternoon sun
    - in a Medellín café surrounded by green hills | light: soft overcast
    - on a train through the Swiss Alps with a laptop open | light: snow-reflected window light

    ## city-break | City break | travel
    look: stylish travel photograph
    camera: 35mm lens
    light: natural daylight
    - on a piazza in Milan, a gothic cathedral's spires behind | wear: a tailored coat and sunglasses
    - on a red-bus-lined street in London | wear: a checked blazer and boots | light: soft grey light
    - in a Barcelona street of modernist balconies | wear: a summer shirt | light: hot sun and sharp shadows
    - by the canals of Venice in a gondola | light: golden evening light
    - on a Lisbon tram climbing a hill | camera: 50mm lens, the tram and street
    - in a Copenhagen harbour of colourful houses | wear: a raincoat and a knit | light: clear Nordic light
    - on the Brooklyn waterfront with Manhattan behind | light: blue hour
    - in a Marrakech square at dusk | light: lantern and smoke glow

    ## desert-luxury | Desert luxury | travel
    look: glossy luxury travel photograph
    camera: 35mm lens
    light: warm golden light
    wear: elegant resort wear and sunglasses
    - on a skyscraper terrace above a desert city at sunset | light: orange sunset haze
    - on a dune at dusk beside a four-by-four | wear: a flowing linen kaftan
    - by a rooftop infinity pool with towers behind | light: hot afternoon sun
    - in a grand hotel lobby with gold detail | light: warm chandeliers
    - on a yacht in a marina of towers at night | light: city lights and water reflections
    - at a desert camp under lanterns | light: lanterns and starlight

    ## urban-exploration | Urban exploration | travel
    look: atmospheric documentary photograph, faded and quiet
    camera: 24mm lens
    light: dusty light through broken windows
    wear: a worn field jacket and boots
    - in a decayed living room with peeling wallpaper | who: {subject} standing in the doorway
    - in an abandoned school hall with overturned chairs | light: shafts of light through dust
    - on a rusted Ferris wheel overgrown with trees | light: overcast and still
    - in a crumbling theatre with a collapsed ceiling | camera: 16mm lens, the room vast
    - on the roof of a derelict factory at dusk | light: fading sunset
    - in a flooded tunnel with a headtorch | light: a single torch beam

    ## americana | Americana road trip | travel
    look: warm American road-trip photograph, film colours
    camera: 35mm lens
    light: big-sky daylight
    wear: a denim jacket, white tee and boots
    - at a roadside diner with chrome stools | light: midday sun through blinds
    - on a long empty desert highway leaning on a classic car | light: hot afternoon
    - at a petrol station at night under a lit canopy | light: fluorescent canopy glow
    - at a county fair with a Ferris wheel | light: golden evening
    - by a lighthouse on a rocky New England coast | wear: a cable-knit sweater
    - among cherry blossoms in a park in spring | light: soft spring daylight
    - on a porch of a wooden farmhouse | light: warm late sun

    ## european-summer | European summer | travel
    look: warm Mediterranean holiday photograph, film-like
    camera: 35mm lens
    light: hot summer sun
    wear: a linen shirt and sunglasses
    - at a lemon grove on the Amalfi coast | light: dappled sun
    - on a Riviera beach with striped umbrellas | wear: swimwear under a loose shirt | camera: high angle
    - riding a vintage scooter along a coast road | camera: 50mm lens, motion
    - at a long lunch table in a vineyard | light: late afternoon
    - in a small harbour of fishing boats in Croatia | light: bright morning
    - at an Alpine village festival with a brass band | wear: a traditional dirndl / a traditional dirndl / leather breeches and a checked shirt

    ## traditional-dress | Traditional dress | travel
    look: respectful cultural portrait, rich colour and fine detail
    camera: 85mm lens, three-quarter figure
    light: soft natural light
    - in a colourful courtyard in Mexico City | wear: an embroidered huipil / an embroidered huipil / a charro suit
    - at a temple garden in Kyoto | wear: a kimono with an obi sash / a patterned kimono / a dark kimono and hakama
    - in a palace courtyard in Rajasthan | wear: a silk sari with gold border / a silk sari / a sherwani and turban
    - in a hanok village in Seoul | wear: a hanbok in soft colours
    - in a Scottish glen with heather | wear: a tartan kilt outfit / a tartan sash and dress / a tartan kilt and sporran
    - at a market in Accra | wear: bright kente cloth
    - in a Moroccan riad courtyard | wear: an embroidered kaftan / an embroidered kaftan / a djellaba
    - by a fjord in Norway | wear: a bunad with silver brooches
    """
}
