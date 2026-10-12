//
//  StyleText+Lifestyle.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  Everyday life, outdoors, wellbeing and the camera's own looks. Written for
//  this library; the format is described in StyleCatalog.swift.
//

extension StyleText {

    static let lifestyle = """
    ## slow-weekend | Slow weekend | lifestyle
    look: soft lifestyle photograph, calm and unhurried
    camera: 35mm lens, natural framing
    light: gentle morning light through linen curtains
    - curled up on a window seat with a novel and a mug of tea | wear: an oversized knit jumper and wool socks
    - in a bright bathroom with candles and plants, applying a clay face mask | wear: a fluffy white bathrobe
    - at a farmhouse table with a slow breakfast of pastries and berries | who: {subject} pouring coffee from a French press
    - arranging fresh flowers in a ceramic jug | camera: 50mm lens, hands and face in frame
    - on a sofa under a blanket watching rain on the window | light: cool grey daylight and a warm lamp
    - on a balcony with a watering can among potted herbs | wear: a loose linen shirt
    - journaling in bed with a breakfast tray | light: bright, airy, white-on-white

    ## mirror-selfie | Mirror selfie | lifestyle
    look: phone mirror selfie, authentic, slight wide-angle distortion
    camera: phone camera held at chest height, phone visible in the reflection
    light: natural indoor light
    - in a hallway with a full-length arched mirror and a coat rack | wear: an everyday outfit of jeans and a cropped jacket
    - in a hotel bathroom with marble and brass fittings | light: warm vanity bulbs
    - in a fitting room with a curtain half drawn | wear: a bold patterned coat being tried on
    - in a lift with mirrored walls | light: cool overhead light
    - in a bedroom with a floor mirror, plants and a rumpled bed behind | light: soft afternoon sun
    - in a gym changing area mirror after a workout | wear: a matching sports set and a towel over one shoulder

    ## lifestyle-influencer | Lifestyle content | lifestyle
    look: polished social media lifestyle photograph, bright and aspirational
    camera: 35mm lens, vertical framing
    light: bright natural light, clean whites
    - at a marble café table with a matcha latte and an open laptop | who: {subject} smiling at the camera
    - walking out of a bakery with a paper bag of baguettes | camera: 50mm lens, full figure, street behind
    - at a sunlit desk with a moodboard pinned above | who: {subject} sketching ideas
    - by a rooftop pool on a sun lounger with a book | wear: a linen shirt over swimwear and sunglasses
    - in a flower shop, holding a huge bouquet of peonies | light: soft shopfront light
    - at a hotel breakfast spread of fruit, coffee and pastries | camera: high angle, the table and subject together
    - packing a suitcase on a bed with neatly folded outfits | camera: overhead view

    ## luxury-living | Luxury living | lifestyle
    look: high-end lifestyle photograph, glossy and cinematic
    camera: 35mm lens, wide and spacious
    light: warm golden-hour light
    wear: tailored resort wear in cream and sand
    - on the deck of a sailing yacht at anchor in a turquoise bay | who: {subject} holding a glass of sparkling water
    - beside an infinity pool that meets the sea | camera: 24mm lens, symmetrical
    - in a penthouse living room with a skyline view at dusk | light: city lights and warm lamps
    - stepping out of a classic convertible on a coastal road | who: {subject} pushing sunglasses up into their hair
    - at a private table in a garden restaurant | light: candlelight and the last sun
    - on a terrace above a marina at night | light: the glow of the harbour lights

    ## into-nature | Into nature | lifestyle
    look: atmospheric outdoor portrait, earthy and free
    camera: 50mm lens, subject small-to-medium in the landscape
    light: soft natural light
    - in a field of ripe wheat at sunset, running fingers across the stalks | light: backlit golden sun
    - in a misty pine forest on a mossy path | light: cool diffuse light with shafts through the trees
    - on a riverbank, sitting on a smooth boulder with bare feet in the water | wear: a loose cotton shirt and rolled trousers
    - in a meadow of wildflowers in early summer | camera: 85mm lens, flowers in the foreground
    - under a huge old oak tree in light rain | wear: a waxed jacket
    - on a sand dune with tall grass bending in the wind | light: hazy late afternoon
    - in a tropical rainforest beside a waterfall | light: green-filtered light and mist

    ## outdoor-adventure | Outdoor adventure | lifestyle
    look: adventure photography, epic landscape, real gear
    camera: 24mm lens, the person small in a big landscape
    light: dramatic natural light
    wear: a technical shell jacket, hiking trousers and a backpack
    - on a ridge above a sea of clouds at sunrise | who: {subject} standing at the edge, looking out
    - kayaking across a still alpine lake at sunset | wear: a life vest and a cap
    - beside a tent on a high plateau under a starry sky | light: a glowing tent and the Milky Way
    - crossing a rope bridge over a jungle gorge | camera: 16mm lens, looking along the bridge
    - on a glacier with crampons and an ice axe | light: bright, blue-white ice
    - by a campfire at dusk on a lakeshore | light: warm firelight against blue twilight | camera: 35mm lens, waist-up
    - mountain biking down a dusty trail | camera: low angle, dust kicked up, motion blur

    ## mindful-movement | Yoga & stillness | lifestyle
    look: serene wellness photograph, quiet and grounded
    camera: 35mm lens, balanced composition
    light: soft early-morning light
    wear: simple neutral activewear
    - holding a yoga pose on a wooden deck above the sea | light: pale sunrise
    - meditating cross-legged in a sunlit studio with plants | who: {subject} with eyes closed
    - in a tree pose in a misty meadow | camera: 50mm lens, full figure
    - walking a forest path barefoot with hands open | light: dappled sunlight
    - on a mat in a bamboo pavilion during a light rain | light: soft, green-grey light
    - sitting by a still lake with a cup of tea at dawn | wear: a wool wrap over activewear

    ## fitness | Fitness | lifestyle
    look: athletic sports photograph, strong and energetic, realistic body
    camera: 35mm lens, dynamic angle
    light: hard natural light
    wear: performance sportswear
    - sprinting along a waterfront path at dawn | camera: low angle, motion blur on the background
    - mid-lift with a barbell in an industrial gym | light: hard overhead light and dark corners
    - jumping rope in a sunlit boxing gym | camera: 1/1000 s, rope frozen mid-air
    - stretching on a track after a run | who: {subject} catching their breath, smiling
    - climbing a steep hill trail at golden hour | camera: 24mm lens, the climb ahead
    - doing pull-ups at an outdoor calisthenics park | light: bright sun and long shadows
    - rowing on a misty river at dawn | wear: a fitted rowing kit

    ## maternity | Maternity | lifestyle
    look: tender maternity photography, soft and warm
    camera: 85mm lens, full or three-quarter figure
    light: soft golden backlight
    wear: a flowing pale maternity dress / a flowing pale maternity dress / a soft linen shirt
    - in a field of tall grass at sunset, hands resting on the bump | who: {subject}, expecting
    - by a big window in a calm nursery | light: soft window light | who: {subject}, expecting, smiling down
    - on a quiet beach with a gentle breeze | who: {subject}, expecting, looking out to sea
    - in a studio against a warm cream backdrop | camera: 50mm lens, side profile | who: {subject}, expecting
    - in a blossoming orchard | light: dappled spring light | who: {subject}, expecting, holding a sprig of blossom
    - at home on a sofa with a partner's hands joined on the bump | light: warm lamplight | who: {subject}, expecting, laughing

    ## soap-bubbles | Soap bubbles | lifestyle
    look: dreamy photograph, playful and luminous
    camera: 85mm lens, bubbles sharp in the foreground and blurred behind
    light: low sun shining through the bubbles
    - in a sunlit meadow surrounded by drifting bubbles | who: {subject} blowing bubbles from a wand
    - on a city rooftop at sunset with giant bubbles floating past | who: {subject} reaching out to touch one
    - close-up with one bubble reflecting the face | camera: 100mm macro, iridescent swirls
    - in a park at golden hour, bubbles everywhere | who: {subject} laughing, spinning around
    - against a dark background with bubbles lit from the side | light: a single hard side light | look: fine-art studio photograph
    - on a beach at dusk with a long trail of bubbles | light: pink and violet sky

    ## with-pets | With pets | lifestyle
    look: warm pet lifestyle photograph, candid and joyful
    camera: 35mm lens, person and animal both sharp
    light: bright natural light
    - on a living-room floor with a golden retriever licking their face | who: {subject} laughing
    - on a sofa with a sleepy tabby cat curled on their lap | light: soft afternoon window light
    - running along a beach with a scruffy terrier | camera: 1/1000 s, sand flying
    - in a backyard training a spaniel with a treat | who: {subject} crouching, the dog sitting attentively
    - on a hiking trail with a husky on a lead | light: crisp mountain light
    - in an armchair with a rabbit in their arms | camera: 50mm lens, waist-up
    - under a duvet with a small dog peeking out | light: cosy morning light

    ## hard-flash | Hard flash | lifestyle
    look: direct-flash photograph, punchy contrast, crisp shadow behind
    camera: 28mm lens, eye level, slightly off-centre
    light: a bare on-camera flash against a darker surrounding
    - against a bare white wall | who: {subject} laughing, head tilted back | wear: a black leather jacket over a white tee
    - in the back seat of a taxi at night | light: flash with city lights streaking past outside
    - in a narrow kitchen at a house party | who: {subject} holding a paper cup, mid-conversation
    - on a night street outside a corner shop | light: flash and the shop's fluorescent spill
    - in a lift with mirrored walls | light: flash bouncing off the mirrors
    - against a red velvet curtain | camera: 50mm lens, head and shoulders | who: {subject} with a deadpan stare
    - sitting on a kerb at night eating fries | camera: low angle

    ## instant-film | Instant film | lifestyle
    look: instant film photograph, soft colours, slight vignette, white frame border
    camera: fixed-focus instant camera, slightly off-level
    light: built-in flash
    - on a sofa at a friend's flat | who: {subject} pulling a face
    - at a beach shack with a cold drink | light: bright sun, faded colours
    - in a kitchen at night | who: {subject} holding up a slice of birthday cake
    - on a road trip leaning against a car at a petrol station | light: harsh midday sun
    - in a bedroom under fairy lights | light: flash mixed with warm fairy lights
    - at a campsite with a tent behind | light: dusk and flash

    ## extreme-close-up | Extreme close-up | lifestyle
    look: extreme close-up portrait, every texture visible, natural skin
    camera: 100mm macro lens, the face filling the frame
    light: soft beauty light with a large catchlight
    - eyes and the bridge of the nose only | who: {subject} looking straight into the lens
    - half the face in light, half in shadow | light: hard window light
    - eyes looking up through eyelashes | light: soft overhead light
    - with water droplets on the skin | light: crisp side light
    - lips and chin with a hand touching the jaw | camera: 85mm lens at f/2, very shallow focus
    - one eye framed by gold-rimmed glasses | light: warm, low sun
    - freckled cheek and eye catching the window | light: soft north-facing window
    """
}
