//
//  StyleText+Imagined.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  Events, fantasy, art and food. Written for this library; the format is
//  described in StyleCatalog.swift.
//

extension StyleText {

    static let events = """
    ## music-festival | Music festival | events
    look: festival photograph, euphoric and sun-washed
    camera: 35mm lens
    light: golden late-afternoon sun
    wear: a boho festival outfit with a fringed vest and boots
    - in the crowd with hands in the air before a big stage | light: stage lights at dusk
    - on a friend's shoulders above the crowd | camera: low angle
    - at a desert festival with giant art installations | light: hot evening sun
    - with glitter on the cheeks, close-up | camera: 85mm lens
    - by a tent at dawn after the last set | light: soft pink dawn
    - under a canopy of coloured flags | light: dappled colour
    - in a crowd at night with lasers overhead | light: green lasers and haze

    ## dj-set | DJ set | events
    look: live music photograph, energetic and cinematic
    camera: 24mm lens from behind the decks, the crowd beyond
    light: stage light and haze
    wear: a black tee and headphones
    - behind the decks at a beach festival at sunset | light: orange sun over the sea
    - in a packed warehouse rave | light: strobes and smoke
    - on a mountain-top stage at golden hour | camera: wide, the valley behind
    - at a rooftop day party | light: bright daylight
    - in a small basement club, one hand on the mixer | light: red light
    - in front of a giant LED wall | light: colour washes from the screen

    ## techno-club | Techno club | events
    look: dark nightclub photograph, gritty and atmospheric
    camera: 28mm lens, flash and slow shutter
    light: strobes in darkness
    wear: all-black club clothes, a mesh top and boots
    - on a crowded industrial dance floor | camera: motion blur on the crowd
    - against a raw concrete wall in a corridor | light: a red bulb
    - in a smoking courtyard at 5 a.m. | light: grey dawn
    - under a single strobe | light: hard white strobe freezing motion
    - at the bar with sweat and fog | light: blue bar light
    - leaving the club at sunrise | light: early morning sun

    ## rooftop-party | Rooftop party | events
    look: stylish nightlife photograph, glamorous and candid
    camera: 35mm lens
    light: sunset and string lights
    wear: a sleek evening outfit
    - at a rooftop bar with a skyline at sunset | who: {subject} laughing with a cocktail
    - on a yacht deck at a sunset party | light: golden sunset over the water
    - by a pool party with floating lights | light: pool glow
    - in a lounge with velvet sofas | light: warm amber light
    - dancing under string lights | camera: motion blur
    - on a terrace at night with the city behind | light: city glow

    ## football-fan | Football fan | events
    look: sports fan photograph, loud and colourful
    camera: 35mm lens
    light: stadium floodlights
    wear: a team-colours jersey and scarf with painted cheeks
    - in a packed stadium stand mid-cheer | who: {subject} with arms raised
    - taking a selfie with the pitch behind | camera: phone selfie angle
    - at a fan zone with a giant screen | light: evening sky and screen glow
    - in a pub with a crowd watching | light: warm pub light
    - celebrating a goal with confetti | camera: 1/1000 s
    - on a street march to the stadium with flares | light: coloured smoke

    ## graduation | Graduation | events
    look: proud graduation photograph, bright and celebratory
    camera: 50mm lens
    light: bright daylight
    wear: a graduation gown and mortarboard
    - on the steps of a university building | who: {subject} holding a rolled diploma
    - throwing a cap into the air | camera: 1/1000 s, low angle
    - in a quad with old stone buildings | camera: 85mm lens
    - with family hugging after the ceremony | camera: 35mm lens
    - in a lecture hall with an empty podium | light: window light
    - under blossoming trees on campus | light: soft spring sun

    ## birthday-picnic | Birthday picnic | events
    look: sweet party photograph, pastel and joyful
    camera: 50mm lens
    light: soft afternoon light
    wear: a pink party dress / a pink party dress with lace gloves / a pink shirt and light trousers
    - with a candlelit cake on a blanket | who: {subject} about to blow out candles
    - under a canopy of ribbons and balloons | light: dappled light
    - with a tower of cupcakes | camera: close-up
    - opening a gift with friends around | camera: 35mm lens
    - with confetti in a garden | camera: 1/500 s
    - holding a bunch of pink balloons | light: backlight
    """

    static let fantasy = """
    ## fairy-tale | Fairy tale | fantasy
    look: enchanted fantasy photograph, soft glow, painterly
    camera: 50mm lens
    light: misty magical light
    wear: a flowing medieval gown in soft pastels / a flowing medieval gown in soft pastels / a velvet tunic and cloak
    - riding a white horse through a misty forest | light: morning mist and rays
    - in a castle garden with roses climbing the walls | light: golden hour
    - by a glowing pond with fireflies | light: fireflies and moonlight
    - in a tower window with long hair falling | camera: low angle
    - in a ballroom with chandeliers | light: candlelight
    - with a fox in a snowy forest | light: blue winter light
    - asleep in a field of poppies | camera: overhead

    ## tarot-card | Tarot card | fantasy
    look: tarot card illustration, ornate border, art nouveau, gold detail, no words
    camera: full figure, symmetrical composition
    light: flat illustrative light
    - as the High Priestess between two pillars | wear: blue robes and a crescent crown
    - as the Magician at a table of symbols | wear: red and white robes
    - as the Star kneeling by a pool | wear: a simple flowing robe
    - as the Empress on a cushioned throne in a wheat field | wear: a gown with pomegranate pattern
    - as the Hermit with a lantern on a mountain | wear: a grey hooded cloak
    - as the Sun on a white horse | wear: a garland of sunflowers
    - as the Moon by a path between two towers | wear: a silver cloak

    ## chibi | Chibi | fantasy
    look: cute chibi character, big head, tiny body, glossy 3D render
    camera: full figure, front view
    light: soft studio light
    - as a tiny samurai with a little katana | wear: a colourful kimono
    - as a wizard with an oversized hat | wear: a starry robe
    - as a chef holding a giant spoon | wear: a chef's hat and apron
    - as an astronaut floating among stars | wear: a puffy spacesuit
    - as a gardener among giant flowers | wear: overalls and a straw hat
    - as a knight with a tiny shield | wear: shiny armour

    ## anime-character | Anime character | fantasy
    look: anime illustration, clean cel shading, vibrant
    camera: dynamic angle
    light: dramatic anime lighting
    - in a neon city at night | wear: an oversized hoodie and sneakers
    - on a school rooftop at sunset | wear: a school-style uniform blazer
    - as a fantasy adventurer with a sword | wear: light armour and a cape
    - in a ramen shop at night | wear: a casual jacket
    - on a train looking out at fields | light: golden hour
    - in a magical library | wear: a mage's robe

    ## anime-line-art | Anime sketch | fantasy
    look: black ink anime line art, clean linework, minimal shading
    camera: full figure
    light: flat
    - flying on a broomstick through clouds | wear: a witch apprentice dress
    - sitting on a crescent moon | wear: a flowing nightgown
    - reading under a tree | wear: casual clothes
    - with a dragon curled around them | wear: a robe
    - in a café with a cat | wear: a sweater
    - on a rooftop with wind in their hair | wear: a long coat

    ## pixel-art | Pixel art | fantasy
    look: 16-bit pixel art, limited palette, crisp pixels
    camera: side view game scene
    light: flat pixel lighting
    - on a nightclub dance floor | wear: a party outfit
    - in a forest dungeon with a sword | wear: adventurer's armour
    - in a city street at night with neon | wear: a jacket
    - on a beach at sunset | wear: summer clothes
    - in a space station | wear: a spacesuit
    - in a cosy pixel bedroom | wear: pyjamas

    ## caricature | Caricature | fantasy
    look: editorial caricature, exaggerated features, ink and watercolour
    camera: head and shoulders
    light: flat illustrative light
    - against a plain cream background | who: {subject} with a huge grin
    - as a chef | wear: a chef's hat
    - as a rock star | wear: a leather jacket
    - as a scientist | wear: a lab coat and goggles
    - as a golfer | wear: a golf outfit
    - as a superhero | wear: a cape

    ## sci-fi-avatar | Sci-fi avatar | fantasy
    look: detailed digital painting, science fiction, intricate
    camera: head and shoulders
    light: cinematic rim light
    - as a cyborg with chrome plates | wear: a high-tech collar
    - as a starship pilot | wear: a flight suit with patches
    - as an elven ranger | wear: a leaf-green cloak
    - as a desert nomad on an alien world | wear: layered robes and goggles
    - as an android with glowing seams | wear: a sleek white bodysuit
    - as a space explorer in a nebula | wear: a spacesuit

    ## animal-character | Animal character | fantasy
    look: cute anthropomorphic animal character, 3D animated film style
    camera: full figure
    light: soft studio light
    - as a red panda in a cosy sweater | who: {subject} as a red panda character
    - as a fox in a detective's coat | who: {subject} as a fox character
    - as a rabbit in a gardener's apron | who: {subject} as a rabbit character
    - as a wolf in a leather jacket | who: {subject} as a wolf character
    - as a cat in a chef's outfit | who: {subject} as a cat character
    - as an owl in a professor's tweed | who: {subject} as an owl character

    ## cosplay | Cosplay | fantasy
    look: cosplay photograph, convention quality costume
    camera: 50mm lens
    light: natural daylight
    - as a stealthy rogue with daggers outside a convention hall | wear: a leather rogue outfit
    - as a space marine in armour | wear: bulky sci-fi armour
    - as a sorceress casting a spell | wear: a dramatic robe
    - as a pirate captain | wear: a tricorn hat and long coat
    - as a ninja | wear: dark wrapped clothing
    - as a steampunk inventor | wear: goggles and brass gadgets

    ## game-hero | Game hero | fantasy
    look: video game cinematic render, high detail
    camera: third-person over-the-shoulder view
    light: dramatic game lighting
    - in a fantasy open world on a cliff | wear: armour and cloak
    - in a post-apocalyptic city | wear: a gas mask and patched gear
    - in a racing game beside a sports car | wear: a racing suit
    - in a space shooter on a ship deck | wear: a power suit
    - in a medieval village | wear: a peasant tunic
    - in a sunny city street | wear: casual streetwear

    ## mars-colony | Life on Mars | fantasy
    look: realistic science-fiction photograph
    camera: 35mm lens
    light: dusty red light
    wear: a sleek white spacesuit
    - in a bar on Mars with red dunes through big windows | wear: an elegant futuristic outfit
    - walking across red dunes with Earth in the sky | camera: wide
    - in a greenhouse dome with plants | light: purple grow lights
    - in a habitat bunk room | light: soft white light
    - on a rover at dusk | light: blue Martian sunset
    - at a viewing deck over a canyon | camera: 24mm lens

    ## action-figure | Action figure | fantasy
    look: toy photograph of a collectible action figure in a clear blister pack, no lettering
    camera: product shot, front view
    light: clean studio light
    - with tiny accessories: a laptop and a coffee cup | wear: a business outfit
    - with a surfboard and sunglasses | wear: beachwear
    - with a camera and backpack | wear: travel clothes
    - with a guitar | wear: a leather jacket
    - with gym weights | wear: sportswear
    - with a paintbrush and palette | wear: a painter's smock

    ## character-sheet | Character sheet | fantasy
    look: 3D character model sheet, T-pose, front view, neutral grey background, clean topology look
    camera: orthographic, full figure, centred
    light: flat even light
    - in casual clothes | wear: a t-shirt and jeans
    - in sportswear | wear: a tracksuit
    - in office clothes | wear: a shirt and trousers
    - in fantasy armour | wear: medieval armour
    - in sci-fi gear | wear: a tactical suit
    - in winter clothes | wear: a parka and boots

    ## cyberpunk | Cyberpunk | fantasy
    look: cyberpunk film still, neon and rain
    camera: 35mm lens
    light: neon signs in rain
    wear: a reflective jacket with LED trim
    - on a crowded street market at night | light: pink and cyan neon
    - on a rooftop over a megacity | light: holograms
    - in a noodle bar under signs | light: warm and neon mix
    - in a subway car with screens | light: screen glow
    - with augmented-reality visor glowing | camera: close-up
    - riding a motorbike through a tunnel | camera: motion blur
    """

    static let art = """
    ## fine-art-portrait | Fine-art portrait | art
    look: classical fine-art painting
    camera: three-quarter portrait
    light: soft painterly light
    - as an oil painting in the Dutch Golden Age manner | light: chiaroscuro window light
    - as a marble sculpture in a gallery | look: white marble sculpture, museum lighting
    - as an impressionist painting in a garden | look: loose impressionist brushwork
    - as a watercolour portrait | look: soft watercolour with paper texture
    - as a mosaic of coloured tiles | look: Byzantine mosaic
    - as a charcoal sketch | look: expressive charcoal drawing on cream paper
    - as a stained-glass window | look: stained glass with lead lines

    ## tattoo-design | Tattoo design | art
    look: tattoo photograph, healed and crisp linework
    camera: close-up on the tattoo
    light: soft studio light
    - with a fine-line floral tattoo wrapping the forearm | who: {subject}, forearm in frame
    - with a small constellation tattoo on the wrist | who: {subject}, wrist in frame
    - with a traditional swallow tattoo on the hand | who: {subject}, hand in frame
    - with a geometric mandala on the shoulder | who: {subject}, shoulder in frame
    - with a botanical sleeve | who: {subject}, arm in frame
    - with a minimalist line portrait on the ankle | who: {subject}, ankle in frame

    ## album-cover | Album cover | art
    look: square album cover art, bold and iconic, no lettering
    camera: square composition
    light: dramatic light
    - as a 1990s hip-hop cover in a car park at night | light: car headlights
    - as a jazz cover in blue tones | look: blue-tinted photograph, smoky
    - as a punk cover in black and white | look: photocopied texture
    - as an indie cover in a field at dusk | light: blue hour
    - as an electronic cover in a chrome room | look: 3D render
    - as a soul cover with warm sunset tones | light: golden sunset

    ## reaction-thumbnail | Reaction face | art
    look: bright video thumbnail style photograph, exaggerated expression, saturated
    camera: close-up, face large in frame
    light: bright ring light
    - against a bright yellow background | who: {subject} with a shocked face, mouth open
    - against a red background | who: {subject} looking stunned, hands on cheeks
    - against a blue background | who: {subject} laughing hysterically
    - against a green background | who: {subject} with a eureka look, finger raised
    - against a purple background | who: {subject} confused, one eyebrow up
    - against an orange background | who: {subject} pointing at the camera with excitement
    """

    static let food = """
    ## food-photography | Food photography | food
    look: cookbook food photograph, appetising, true colour
    camera: 50mm lens, shallow depth of field
    light: soft side window light
    - on a rustic wooden table with linen napkins | who: {subject}
    - on a marble counter with scattered herbs | who: {subject} | camera: overhead
    - on a dark slate with dramatic shadows | who: {subject} | light: low-key side light
    - at a sunny garden table | who: {subject} | light: dappled sun
    - with steam rising in a cosy kitchen | who: {subject} | light: warm light
    - on a pastel background | who: {subject} | look: playful food styling
    - on a picnic blanket | who: {subject} | light: bright daylight
    - on a restaurant pass | who: {subject} | light: warm pass lights
    """
}
