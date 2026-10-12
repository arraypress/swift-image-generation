//
//  StyleText+Fashion.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  Aesthetics, outfits and grooming. Written for this library; the format is
//  described in StyleCatalog.swift.
//

extension StyleText {

    static let fashion = """
    ## old-money | Old money | fashion
    look: heritage editorial photograph, understated and moneyed, muted palette
    camera: 85mm lens, three-quarter figure
    light: soft overcast daylight
    wear: a cream cable-knit sweater over a collared shirt / a cream cable-knit sweater draped over the shoulders, pleated skirt and pearl studs / a navy blazer, cream trousers and loafers
    - on the stone terrace of a country house with clipped hedges | who: {subject} resting a hand on the balustrade
    - beside a grass tennis court holding a wooden racket | wear: crisp tennis whites
    - at a polo field edge with horses blurred behind | light: bright breezy afternoon
    - on a sailing dinghy at a lakeside club | wear: a striped boat-neck top and white trousers
    - in a wood-panelled library with a leather armchair | light: warm lamplight
    - walking a golden retriever down a gravel drive lined with cypress trees | camera: 50mm lens, full figure
    - on the steps of an old university quad | wear: a camel overcoat over a roll-neck

    ## quiet-luxury | Quiet luxury | fashion
    look: minimalist luxury fashion photograph, tonal and refined
    camera: 50mm lens, full figure, generous negative space
    light: soft diffuse daylight
    wear: layered cashmere and wool in cream, camel and taupe
    - in a gallery with white walls and a single sculpture | who: {subject} standing still, hands in pockets
    - in a concrete-and-oak apartment with a long low sofa | camera: 35mm lens
    - against a sandstone wall in late sun | light: warm raking light
    - on a quiet street of limestone townhouses | who: {subject} mid-stride, glancing down
    - in a hotel lobby of travertine and linen | wear: a long camel coat over a fine-knit set
    - seated at a bare oak table with one ceramic cup | camera: 85mm lens, waist-up

    ## clean-minimal | Clean & minimal | fashion
    look: fresh, polished lifestyle photograph, glowing natural skin
    camera: 50mm lens, waist-up
    light: bright soft morning light
    wear: crisp linen in white and beige with a fine gold chain
    - at an outdoor café table with a green juice | who: {subject} with hair pulled back neatly
    - in a white-tiled kitchen slicing citrus | camera: 35mm lens
    - on a balcony with olive trees in pots | light: warm, clean sunlight
    - walking through a sunny market with a woven bag | camera: full figure, street behind
    - by a bathroom window, hair in a towel turban | light: soft frosted-glass light
    - on a yoga mat rolling it up after class | wear: a matching neutral activewear set

    ## romantic-picnic | Romantic picnic | fashion
    look: soft romantic photograph, pastel and whimsical, film-like
    camera: 50mm lens, shallow depth of field
    light: hazy afternoon sun
    wear: a gingham dress with a ribbon in the hair / a puff-sleeve gingham dress with a ribbon in the hair / a soft cream shirt and a knitted vest
    - on a checked blanket in a rose garden with strawberries and scones | who: {subject} pouring lemonade
    - under a lace parasol by a lily pond | camera: 85mm lens, waist-up
    - in an orchard with a wicker basket of cherries | light: dappled sunlight
    - at a garden tea table set with mismatched china | who: {subject} laughing over a teacup
    - in a field of daisies weaving a flower crown | light: soft backlight
    - on a wooden swing hanging from a big tree | camera: 35mm lens, full figure

    ## dark-academia | Dark academia | fashion
    look: moody scholarly photograph, deep browns and greens, film grain
    camera: 50mm lens, waist-up
    light: low warm lamplight and dim window light
    wear: a tweed blazer over a roll-neck / a pleated tartan skirt, roll-neck and long coat / a tweed blazer, roll-neck and wool trousers
    - writing with a fountain pen at a desk crowded with old books | light: a green banker's lamp
    - in a gothic library under vaulted wooden ceilings | camera: 24mm lens, the room towering
    - walking through a stone cloister on a foggy morning | light: cold grey fog
    - beside a fireplace reading a leather-bound book | light: firelight
    - in a dusty museum hall of specimen cabinets | who: {subject} examining a pinned moth under glass
    - on a staircase in an old college with an armful of books | camera: 35mm lens, low angle

    ## gorpcore | Gorpcore | fashion
    look: outdoor-tech fashion photograph, bold colour against the landscape
    camera: 35mm lens, full figure
    light: crisp mountain daylight
    wear: a bright technical shell jacket, fleece, trail shoes and a beanie
    - on a rocky trail above a valley | who: {subject} adjusting a backpack strap
    - in a snowy car park beside a camper van | wear: an oversized puffer jacket and snow boots
    - on a city street in full outdoor gear | camera: 50mm lens, urban background soft
    - by a frozen lake with a thermos | light: blue-hour cold
    - at a mountain hut terrace | who: {subject} sitting on a bench, boots unlaced
    - in pouring rain with the hood up, laughing | light: grey and wet, colours popping

    ## street-style | Street style | fashion
    look: fashion-week street style photograph, candid and sharp
    camera: 85mm lens, full figure, background compressed
    light: natural city daylight
    - crossing a busy street in a long tailored coat | wear: a long tailored coat over a monochrome outfit
    - outside a stone museum in a bold checked suit | who: {subject} mid-stride
    - leaning on a scooter on a cobbled side street | wear: a cropped leather jacket and wide trousers
    - under a railway bridge in an oversized trench coat | light: soft shade with bright street behind
    - on stone steps in a colourful knit and wide jeans | camera: 50mm lens, low angle
    - in light rain with a clear umbrella and a sharp suit | light: grey with wet reflections
    - at a crossing in a vintage leather jacket and sunglasses | light: hard afternoon sun, long shadows

    ## mob-glamour | Gangster glamour | fashion
    look: 1970s crime-drama glamour, rich and flashy, film grain
    camera: 50mm lens, waist-up
    light: warm tungsten light with deep shadows
    wear: a faux fur coat, chunky gold jewellery and big sunglasses / a faux fur coat over a leopard dress, gold hoops and big sunglasses / a double-breasted suit, gold rings and a silk pocket square
    - in a red-leather booth at an old Italian restaurant | who: {subject} holding an espresso cup
    - stepping out of a long black vintage sedan at night | light: street lamps and headlights
    - in a smoky back room around a card table | light: one hanging lamp
    - at a seafront promenade in winter | light: pale cold sun
    - on a fire escape in the city | camera: 35mm lens, low angle
    - in a social club bar with framed photos on the wall | light: amber light and neon beer signs

    ## puffer-coat | Puffer coat | fashion
    look: winter fashion editorial, playful and graphic
    camera: 35mm lens, full figure
    light: soft winter light
    wear: an enormous glossy quilted puffer coat with a huge hood
    - on a snowy city square | who: {subject} with hands deep in the pockets
    - against a bright blue studio backdrop | light: clean studio light | look: graphic fashion studio photograph
    - on an icy pier by a frozen harbour | light: pale blue light
    - in a forest of snow-laden pines | who: {subject} laughing as snow falls from a branch
    - on a subway platform at night | light: fluorescent light and a passing train blur
    - in a field of fresh snow lying back, arms out | camera: overhead view

    ## silk-headscarf | Silk headscarf | fashion
    look: elegant fashion portrait, rich prints and colour
    camera: 85mm lens, head and shoulders
    light: soft natural light
    wear: a patterned silk scarf tied over the hair with statement earrings
    - against a warm terracotta wall | who: {subject} looking over a shoulder
    - in an open-top classic car on a coastal road | light: bright sun and wind | camera: 50mm lens, waist-up
    - in a busy spice market | light: warm dappled shade
    - on a hotel balcony above the sea | wear: a silk scarf knotted under the chin and large sunglasses
    - against a deep green backdrop | light: soft studio key light
    - walking along a palm-lined boulevard | camera: full figure

    ## earth-tones | Earth tones | fashion
    look: rich colour-story fashion photograph in chocolate, caramel and tan
    camera: 50mm lens, three-quarter figure
    light: warm late-afternoon light
    wear: a chocolate silk shirt, caramel wide trousers and a tan suede jacket
    - against a clay-plastered wall | who: {subject} leaning back with one foot up on the wall
    - in a café with walnut panelling and amber lamps | light: warm interior light
    - in an autumn vineyard | light: golden haze
    - against a backdrop of the same mocha brown | look: tonal studio fashion photograph
    - on a sandstone staircase | camera: 35mm lens, low angle
    - in a leather-goods workshop | who: {subject} running a hand over a hide

    ## all-ivory | All ivory | fashion
    look: airy fashion photograph, soft whites and off-whites, ethereal
    camera: 85mm lens, full figure
    light: soft diffuse daylight, almost shadowless
    wear: ivory silk and off-white wide trousers with a long cream coat
    - in a white-washed stone courtyard | who: {subject} standing in a doorway
    - on a pale sand beach under a grey-white sky | light: bright overcast
    - against sheer curtains moving in the breeze | camera: 50mm lens
    - in a snowy landscape with a white sky | light: high-key winter light
    - in an empty white gallery | look: minimalist fashion editorial
    - on a terrace of white marble steps | camera: 35mm lens, low angle

    ## suit-fitting | Suit fitting | fashion
    look: menswear and tailoring editorial, sharp and polished
    camera: 50mm lens, full figure
    light: soft studio key with a clean background
    wear: a slim charcoal suit with a light blue shirt and a pocket square / a slim charcoal trouser suit with a silk camisole / a slim charcoal suit with a light blue shirt and a pocket square
    - in a tailor's shop with bolts of cloth behind | who: {subject} adjusting a cuff
    - against a plain light-grey backdrop | look: catalogue fashion photograph, even lighting
    - in a navy double-breasted suit against a marble wall | wear: a navy double-breasted suit
    - in a tuxedo on hotel stairs | wear: a black tuxedo / a black tuxedo-style trouser suit / a black tuxedo with a bow tie
    - in a linen suit on a sunny terrace | wear: a sand-coloured linen suit | light: bright summer sun
    - in a three-piece tweed suit in a wood-panelled room | wear: a brown tweed three-piece suit

    ## outfit-try-on | Outfit try-on | fashion
    look: clean e-commerce fashion photograph, true colours, full outfit visible
    camera: 50mm lens, full figure, centred
    light: soft even studio light
    - against a seamless white backdrop | wear: a fitted rib-knit midi dress / a fitted rib-knit midi dress / a fitted rib-knit polo and tailored trousers
    - against a warm beige backdrop | wear: a denim jacket, white tee and straight jeans
    - against a pale grey backdrop | wear: a belted trench coat over a knit
    - against a soft pink backdrop | wear: a bright tracksuit and white trainers
    - against a sage backdrop | wear: a linen co-ord set
    - against a cream backdrop | wear: a leather jacket, black jeans and boots
    - against a light blue backdrop | wear: a smart blazer, shirt and chinos

    ## runway | Runway | fashion
    look: fashion show photograph, the runway moment
    camera: 200mm lens from the end of the runway, compressed
    light: bright runway spotlights with a dark audience
    wear: an avant-garde designer look
    - striding toward the camera on a long white runway | who: {subject} with a fierce, neutral expression
    - turning at the end of a mirrored runway | camera: 85mm lens
    - on a runway built in an industrial hall with smoke | light: hard backlight and haze
    - on a runway through a garden of flowers | light: soft daylight
    - backstage being fitted, a rail of clothes behind | camera: 35mm lens, candid | light: makeup-mirror bulbs
    - in the finale line of the show | camera: wide, the whole runway

    ## jewellery-campaign | Jewellery campaign | fashion
    look: luxury jewellery advertising photograph, flawless and dramatic
    camera: 100mm lens, close crop
    light: controlled studio light with sparkling highlights
    wear: a simple black top
    - against black velvet, a diamond necklace catching the light | who: {subject} with chin raised
    - with stacked gold rings, a hand resting at the jaw | camera: 100mm macro
    - with long drop earrings against a deep emerald backdrop | light: soft key with a hard accent
    - with a pearl choker, side profile | camera: 85mm lens
    - with a gold cuff bracelet, arm across the body | light: warm golden light
    - with a tennis bracelet on a hand holding a champagne coupe | light: dim and glittering

    ## urban-glamour | Urban glamour | fashion
    look: edgy fashion editorial, high contrast, attitude
    camera: 35mm lens, low angle
    light: hard light and deep shadows
    wear: a sharp leather coat, a black monochrome outfit and boots
    - in a concrete underpass with graffiti | light: harsh daylight cutting across
    - on a rooftop with water towers at dusk | light: sunset rim light
    - in a car park stairwell | light: green fluorescent light
    - against a corrugated metal wall | light: hard noon sun
    - in a neon-lit alley at night | light: magenta and cyan neon
    - on a fire escape in the rain | light: streetlight and wet reflections

    ## alt-style | Alt style | fashion
    look: alternative fashion portrait, playful and dark
    camera: 50mm lens, waist-up
    light: neon-tinted light
    wear: layered black streetwear, chains, striped sleeves and chunky boots
    - in a bedroom lit with purple LED strips | who: {subject} with graphic eyeliner
    - on a night street of glowing vending machines | light: vending-machine glow
    - in a gaming chair with headphones around the neck | light: monitor glow
    - in an arcade among blinking cabinets | light: multicolour arcade light
    - against a pink-and-teal split-lit wall | light: two coloured gels
    - outside a record shop in the rain | light: shop window glow

    ## neon-portrait | Neon portrait | fashion
    look: cinematic studio portrait, saturated coloured light
    camera: 85mm lens, head and shoulders
    light: red and blue gels from opposite sides
    wear: a simple black top
    - against a dark backdrop | who: {subject} looking over a shoulder
    - with smoke drifting in the coloured beams | light: magenta and cyan with haze
    - with a light rain effect lit from behind | light: blue backlight and red key
    - with a neon tube glowing in the background | light: pink neon and soft fill
    - eyes closed, face tilted up into green and violet light | light: green from below, violet from above
    - in profile with an orange rim light | light: single orange rim light, the rest dark

    ## editorial-portrait | Fashion editorial | fashion
    look: high-fashion magazine editorial, artful composition
    camera: 50mm lens, considered framing
    light: sculpted studio light
    - against a giant painted backdrop of clouds | wear: a sculptural white shirt
    - surrounded by hanging sheets of coloured paper | wear: a bold primary-colour suit
    - lying on a floor of scattered petals | camera: overhead view | wear: a pale silk outfit
    - framed in a doorway of a brutalist building | wear: a long monochrome coat | light: hard sun
    - in a field of tall reeds with a long cape blowing | light: overcast and moody
    - reflected in a cracked mirror | wear: a sequinned jacket | camera: 85mm lens
    - against a bright yellow wall with one deep shadow | light: hard sun, graphic shadow

    ## hairstyles | Hairstyle try-on | fashion
    look: salon portrait, the hairstyle clear and well lit
    camera: 85mm lens, head and shoulders
    light: soft beauty lighting
    wear: a plain neutral top
    - against a pale backdrop | who: {subject} with a sleek blunt bob
    - against a pale backdrop | who: {subject} with long soft waves and curtain bangs
    - against a pale backdrop | who: {subject} with a short textured crop
    - against a pale backdrop | who: {subject} with natural defined curls
    - against a pale backdrop | who: {subject} with a high sleek ponytail
    - against a pale backdrop | who: {subject} with a tousled shag cut and layered fringe
    - against a pale backdrop | who: {subject} with a buzz cut
    - against a pale backdrop | who: {subject} with a low textured bun

    ## beard-styles | Beard try-on | fashion
    look: grooming portrait, the beard clear and well lit
    camera: 85mm lens, head and shoulders
    light: soft studio light from one side
    wear: a plain dark crewneck
    - against a warm grey backdrop | who: {subject} with a short, neat boxed beard
    - against a warm grey backdrop | who: {subject} with heavy designer stubble
    - against a warm grey backdrop | who: {subject} with a full, long natural beard
    - against a warm grey backdrop | who: {subject} with a trimmed goatee
    - against a warm grey backdrop | who: {subject} with a groomed moustache and clean jaw
    - against a warm grey backdrop | who: {subject} clean-shaven

    ## makeup-looks | Makeup looks | fashion
    look: beauty editorial close-up, skin texture kept
    camera: 100mm lens, face filling the frame
    light: soft beauty dish with a clean catchlight
    - against a soft pink backdrop | who: {subject} with dewy skin, rosy blush and a glossy lip
    - against a dark backdrop | who: {subject} with a smoky bronze eye and nude lip
    - against a white backdrop | who: {subject} with a sharp graphic liner in electric blue
    - against a peach backdrop | who: {subject} with freckles, a bare face and tinted balm
    - against a deep red backdrop | who: {subject} with a classic red lip and winged liner
    - against a lilac backdrop | who: {subject} with pastel eyeshadow and small rhinestones
    """
}
