//
//  StyleText+People.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  Dating profiles and couples. Written for this library; the format is
//  described in StyleCatalog.swift.
//

extension StyleText {

    static let dating = """
    ## dating-profile | Dating profile | dating
    look: natural, flattering photo taken by a friend, real and unposed
    camera: 50mm lens, waist-up, background softly blurred
    light: warm golden-hour daylight
    - at a busy farmers' market holding a paper bag of peaches | who: {subject} laughing at something off camera | wear: a light denim jacket over a striped tee
    - on a park bench under autumn trees | wear: a chunky knit sweater and a scarf / a chunky knit sweater and a midi skirt / a chunky knit sweater and dark jeans
    - at a sunny café terrace with an espresso | who: {subject} looking up from a book with a smile
    - on a coastal clifftop path with the sea behind | wear: a windbreaker over a hoodie | light: bright breezy afternoon
    - in a cosy bookshop between tall shelves | camera: 35mm lens | light: warm interior light
    - on a city bridge at blue hour with lights coming on | wear: a smart wool coat | light: soft dusk with city lights behind
    - in a kitchen, mid-way through making pasta from scratch | who: {subject} with flour on their hands, grinning
    - close-up portrait against an ivy-covered wall | camera: 85mm lens, head and shoulders | who: {subject} with a warm, genuine smile

    ## dating-adventurous | Dating: out and about | dating
    look: candid lifestyle photo, energetic and real
    camera: 35mm lens, full figure in the scene
    light: bright natural daylight
    - at the top of a mountain trail with a valley below | who: {subject} with arms raised, catching their breath | wear: a technical shell jacket and a cap
    - paddling a kayak across a glassy lake | who: {subject} looking back over a shoulder
    - at a climbing gym, chalking up below a colourful wall | wear: a fitted tee and climbing trousers
    - cycling along a seafront promenade | who: {subject} smiling into the wind | camera: 50mm lens, panning blur in the background
    - at a pottery wheel, hands shaping wet clay | who: {subject} concentrating, then laughing
    - on a sailing boat holding a rope, the sail full behind | wear: a navy striped top and a light waterproof
    - playing guitar on a sunny park lawn | who: {subject} singing along, eyes half closed
    - at an outdoor food market at night, holding a paper tray of dumplings | light: string lights and lantern glow

    ## date-night | Date night | dating
    look: stylish evening photograph, warm and romantic but candid
    camera: 50mm lens at f/1.8, waist-up, creamy bokeh
    light: warm low light from candles and lamps
    wear: a smart dark outfit / a silk slip-style midi dress under a tailored jacket / a dark open-collar shirt and a slim jacket
    - at a candlelit table in a small wine bar | who: {subject} raising a glass, mid-laugh
    - on a rooftop bar with a city skyline glittering behind | light: dusk sky and soft string lights
    - outside a neon-lit cinema on a rainy evening | who: {subject} under a clear umbrella | light: colourful reflections on wet pavement
    - at a jazz club booth with a band blurred on stage | light: amber stage light and table lamps
    - walking along a riverside path lined with lanterns | camera: 35mm lens, full figure
    - at the counter of a busy ramen bar | who: {subject} turning to smile at the camera | light: warm overhead pendant lights
    """

    static let couples = """
    ## couple-portrait | Couple portrait | couples
    look: natural couple photography, affectionate and unposed
    camera: 50mm lens, both people in frame, background soft
    light: soft golden-hour light
    - walking hand in hand through an autumn park with leaves underfoot | who: {subject} | wear: cosy knitwear and wool coats
    - sharing an umbrella on a rainy city street | who: {subject} laughing together | light: overcast with glowing shop windows
    - side by side on a checked rug with a fruit basket | who: {subject} leaning into each other
    - on a beach at sunset, foreheads almost touching | camera: 85mm lens, waist-up
    - cooking together in a sunny kitchen | who: {subject} mid-laugh, one feeding the other a spoonful of sauce
    - wrapped in one blanket on a mountain overlook | light: cool morning mist and first sun
    - dancing in a living room with fairy lights | light: warm lamplight | camera: 35mm lens, slight motion blur

    ## engagement-shoot | Engagement shoot | couples
    look: romantic engagement photography, cinematic and timeless
    camera: 85mm lens at f/2, shallow depth of field
    light: soft, glowing backlight
    wear: elegant smart clothes in soft neutral tones
    - in a field of tall golden grass at sunset | who: {subject} embracing, the sun behind them
    - on a misty lakeside jetty at dawn | who: {subject} holding hands, looking at each other
    - under a single umbrella in gentle rain on a cobbled street | light: moody blue dusk and warm street lamps
    - among the columns of an old stone colonnade | camera: 35mm lens, wide, small figures in grand architecture
    - in a blossoming orchard with petals drifting | who: {subject} laughing, one spinning the other
    - on a rooftop at blue hour with the city below | light: cool dusk with warm fairy lights
    - close-up of clasped hands showing an engagement ring | camera: 100mm macro lens | who: {subject}, only their hands in frame

    ## wedding-day | Wedding day | couples
    look: fine-art wedding photography, airy and elegant
    camera: 85mm lens, soft focus fall-off
    light: bright soft daylight
    wear: wedding attire / a flowing ivory wedding gown and a fine veil / a tailored wedding suit, a flower pinned at the lapel
    - in a sunlit room by a tall window, getting ready for the ceremony | who: {subject} adjusting a cufflink or a veil
    - walking down a garden aisle lined with white flowers | camera: 50mm lens, full figure
    - under a floral arch at an outdoor ceremony | who: {subject} exchanging vows
    - on the steps of an old stone church with confetti in the air | light: bright midday with the confetti backlit
    - at a long reception table under festoon lights | light: warm evening light and candle glow | who: {subject} laughing during a toast
    - on a quiet hilltop at sunset after the ceremony | who: {subject} silhouetted in a soft embrace
    - on a dance floor during the first dance | light: soft spotlight and warm haze | camera: 35mm lens, slight motion

    ## anniversary-through-time | Through the ages | couples
    look: period photograph of the era named, true to its clothes and its film
    camera: 50mm lens, full figure
    light: natural light of the setting
    - in a Renaissance courtyard in rich period dress | who: {subject} posed formally side by side | look: painterly portrait in the manner of a 16th-century oil painting
    - on a Victorian promenade by the sea in period costume | look: sepia albumen print, soft focus edges
    - at a 1920s jazz-age party in evening wear | look: black-and-white photograph, flash, film grain
    - on the steps of a 1950s suburban house beside a two-tone car | look: faded 1950s slide-film colour photograph
    - at a 1970s summer festival in flared denim and fringed suede | look: warm, slightly washed-out 35mm film
    - in a 1990s mall photo booth strip | look: grainy disposable-camera flash photograph
    - on a sleek balcony of a far-future city | look: clean science-fiction film still | light: soft cool light and holographic signs
    """
}
