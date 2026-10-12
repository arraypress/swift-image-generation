//
//  StyleText+Headshots.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  Work portraits: the picture on a team page, a profile, a book jacket.
//  Written for this library; the format is described in StyleCatalog.swift.
//

extension StyleText {

    static let headshots = """
    ## corporate-headshot | Corporate headshot | headshots
    look: professional corporate headshot, natural skin texture, sharp focus on the eyes
    camera: 85mm lens at f/4, head and shoulders, eye level
    light: large soft key light from one side with gentle fill
    wear: a charcoal blazer over a crisp white shirt / a charcoal blazer over a silk shell top / a charcoal suit jacket, white shirt, no tie
    - against a seamless mid-grey paper backdrop | who: {subject} with a relaxed, assured half smile
    - in front of a softly blurred glass-walled office | who: {subject} turned slightly to camera, arms loosely folded
    - against a pale blue-grey backdrop with a faint gradient | wear: a navy blazer over a light blue shirt
    - beside a tall window in a bright meeting room | light: diffuse window light with a white bounce card
    - against a warm oatmeal-coloured wall | who: {subject} with a friendly, open smile | wear: a soft camel knit under a tailored jacket
    - in a modern lobby with pale stone and plants far behind | camera: 105mm lens, chest-up crop, shallow depth of field
    - against a deep charcoal backdrop with a subtle rim light | light: soft key light and a thin edge light separating hair from background
    - in a quiet library-style boardroom with wood panelling out of focus | who: {subject} seated, leaning forward slightly

    ## executive-portrait | Executive portrait | headshots
    look: editorial executive portrait for an annual report, refined and calm
    camera: 70mm lens, waist-up, slightly below eye level
    light: soft directional key with a dark, controlled falloff
    wear: a tailored navy suit / a tailored navy trouser suit with a silk blouse / a tailored navy suit, white shirt and a dark tie
    - in a corner office high above a city skyline at dusk | who: {subject} standing by the floor-to-ceiling window
    - at the head of a long walnut boardroom table | who: {subject} with hands resting on the table
    - against a dark textured backdrop | camera: 85mm lens, head and shoulders | who: {subject} with a composed, direct gaze
    - in a minimalist reception area of polished concrete and brass | light: clean overhead light with soft fill
    - walking along a glass corridor between offices | who: {subject} mid-stride, glancing toward the camera | camera: 50mm lens, full figure, motion in the background
    - seated in a leather armchair in a book-lined study | wear: a dark cashmere jacket over an open-collar shirt
    - on a rooftop terrace with the financial district behind | light: overcast sky, even and flattering

    ## startup-founder | Startup founder | headshots
    look: candid documentary-style portrait for a company website
    camera: 35mm lens, environmental portrait
    light: natural daylight from big warehouse windows
    wear: a plain crewneck sweater over a t-shirt / a relaxed linen shirt / a navy overshirt over a plain tee
    - in a converted brick warehouse office with long shared desks | who: {subject} perched on the edge of a desk
    - in front of a whiteboard covered in boxes and arrows | who: {subject} holding a marker, mid-explanation
    - at a standing desk with two monitors glowing softly | who: {subject} looking up from a laptop with a grin
    - in a small glass meeting pod with sticky notes on the wall | camera: 50mm lens, waist-up
    - on a staircase in a bright co-working building | who: {subject} leaning on the railing
    - at a café counter with a laptop and a flat white | wear: a white tee under a washed denim jacket
    - against a painted concrete wall in a hallway | camera: 85mm lens, head and shoulders | look: clean team-page headshot, friendly and approachable

    ## healthcare-professional | Healthcare professional | headshots
    look: trustworthy healthcare portrait for a clinic website, warm and clean
    camera: 85mm lens, chest-up
    light: bright soft light with no harsh shadows
    wear: a white coat over light blue scrubs, stethoscope around the neck
    - against a pale clinical-white backdrop | who: {subject} with a reassuring smile
    - in a modern consultation room with a desk and a softly blurred anatomy poster | who: {subject} seated, hands clasped
    - in a bright hospital corridor with soft green accents | camera: 50mm lens, waist-up
    - in a dental surgery with the patient chair blurred behind | wear: fitted navy scrubs | who: {subject} holding a dental mirror loosely
    - at a nurses' station with monitors glowing in the background | wear: ceil-blue scrubs and a lanyard
    - beside a large window in a calm waiting area with plants | light: diffuse window light
    - against a soft teal backdrop | camera: 105mm lens, head and shoulders | look: polished staff-directory headshot

    ## wellness-practitioner | Therapist & coach | headshots
    look: warm, gentle portrait for a therapy or coaching practice
    camera: 50mm lens, waist-up, soft background
    light: soft late-morning window light
    wear: a soft oatmeal knit cardigan / a soft cardigan over a simple dress / a soft knit sweater over a collared shirt
    - in a calm consulting room with an armchair, a lamp and a trailing plant | who: {subject} seated, leaning in attentively
    - beside a window with sheer curtains and a pot of eucalyptus | who: {subject} with a kind, listening expression
    - against a sage-green wall | camera: 85mm lens, head and shoulders
    - on a garden bench with greenery softly blurred | light: open shade on a bright day
    - at a small round table with a notebook and a cup of tea | who: {subject} smiling warmly
    - in a light-filled studio with wooden floors and floor cushions | wear: relaxed linen layers in sand tones

    ## lawyer-headshot | Lawyer | headshots
    look: authoritative legal portrait, crisp and understated
    camera: 85mm lens, head and shoulders
    light: soft key light with deeper shadows on one side
    wear: a dark three-piece suit / a dark tailored suit jacket and a cream blouse / a dark suit, white shirt and a burgundy tie
    - in front of shelves of bound law reports | who: {subject} with a measured, confident look
    - against a deep navy backdrop | who: {subject} with arms folded
    - in a wood-panelled conference room | camera: 50mm lens, waist-up
    - on stone courthouse steps with columns out of focus | light: bright overcast daylight
    - at a desk with a fountain pen and a stack of files | who: {subject} looking up from reading
    - in a modern glass office with the city behind | wear: a charcoal suit with a subtle pinstripe

    ## real-estate-agent | Real estate agent | headshots
    look: bright, welcoming portrait for property listings
    camera: 50mm lens, waist-up
    light: bright natural light, airy and clean
    wear: a light grey blazer over a simple top / a fitted blazer over a silk blouse / a light grey blazer with an open-collar shirt
    - in the doorway of a renovated townhouse with a glossy black door | who: {subject} smiling, holding a set of keys
    - in a sunlit open-plan kitchen with a marble island | who: {subject} leaning on the counter
    - on a tidy front lawn with a modern house behind | light: soft afternoon sun
    - against a clean white wall | camera: 85mm lens, head and shoulders
    - on a balcony overlooking a leafy residential street | who: {subject} with a relaxed, approachable smile
    - in a bright living room staged with neutral furniture | camera: 35mm lens, full room visible behind

    ## teacher-headshot | Teacher | headshots
    look: friendly school staff portrait, natural and approachable
    camera: 50mm lens, chest-up
    light: soft classroom daylight
    wear: a cosy knit cardigan over a collared shirt
    - in front of a bright classroom wall of maps and student artwork | who: {subject} smiling warmly
    - beside a chalkboard with faint equations | who: {subject} holding a piece of chalk
    - in a school library between tall shelves | camera: 85mm lens, head and shoulders
    - at a desk with a stack of exercise books and a mug | who: {subject} looking up mid-marking
    - in a sunlit school courtyard with trees | light: open shade, soft and even
    - in a science lab with glassware on the bench behind | wear: a lab coat over a jumper

    ## author-portrait | Author portrait | headshots
    look: book-jacket author portrait, thoughtful and literary
    camera: 85mm lens, head and shoulders
    light: soft window light falling off into shadow
    wear: a roll-neck sweater / a fine-knit roll-neck and a simple pendant / a roll-neck sweater under a tweed jacket
    - in a study lined with overflowing bookshelves | who: {subject} with chin resting on one hand
    - at a writing desk with a typewriter and scattered pages | camera: 50mm lens, waist-up
    - against a weathered plaster wall | who: {subject} with a quiet, inward expression | look: black-and-white author portrait, fine grain
    - in a corner armchair beside a reading lamp | light: warm lamplight and cool window light mixing
    - walking along a windswept coastal path | camera: 85mm lens, waist-up, background soft | light: overcast and moody
    - in an old café with marble tables and a notebook open | who: {subject} pen in hand, looking out of the window

    ## actor-headshot | Actor headshot | headshots
    look: casting headshot, honest and natural, minimal retouching
    camera: 85mm lens at f/2.8, head and shoulders, eyes on the lens
    light: soft daylight with a subtle catchlight
    wear: a plain dark crewneck top
    - against a smooth light-grey backdrop | who: {subject} with a neutral, open expression
    - against a dark backdrop for a dramatic read | who: {subject} with an intense, still gaze | light: single soft key, deep shadow side
    - outdoors in open shade against a softly blurred brick wall | who: {subject} with a warm, easy smile
    - against a blue-grey backdrop | who: {subject} with a mischievous, about-to-laugh grin | wear: a denim shirt
    - in natural light by a big window | camera: 105mm lens, tight head crop
    - against a mustard-coloured wall | who: {subject} with a playful smirk and raised eyebrow | look: comedy casting headshot, bright and characterful

    ## chef-portrait | Chef | headshots
    look: restaurant chef portrait for a menu or press feature
    camera: 50mm lens, waist-up
    light: warm kitchen light with a strong key
    wear: a white double-breasted chef's jacket and a dark apron
    - in a busy stainless-steel kitchen with flames on the range behind | who: {subject} with arms folded and a proud look
    - at the pass, plating a dish with tweezers | who: {subject} focused on the plate | camera: 35mm lens
    - in a herb garden behind the restaurant | who: {subject} holding a bunch of fresh basil | light: soft morning daylight
    - at a wooden prep table covered in vegetables and knives | who: {subject} smiling, mid-chop
    - against a dark wall with copper pans hanging | camera: 85mm lens, head and shoulders | light: moody low-key light
    - at a market stall choosing produce | wear: a denim apron over a white tee

    ## musician-portrait | Musician | headshots
    look: music press portrait, characterful and slightly gritty
    camera: 35mm lens, waist-up
    light: moody available light
    wear: a worn leather jacket over a black tee
    - in a graffiti-covered alley at night | who: {subject} leaning against the wall | light: a single streetlight and neon spill
    - in a rehearsal room with amplifiers and tangled cables | who: {subject} holding an electric guitar
    - at a piano in an empty concert hall | wear: a dark velvet jacket | light: one warm spotlight
    - backstage, sitting on a flight case | who: {subject} with headphones around the neck
    - in a recording studio behind the mixing desk | light: warm desk lamps and glowing meters
    - on a rooftop at golden hour with a city behind | camera: 85mm lens, head and shoulders
    - in a record shop between crates of vinyl | wear: a faded vintage tee and an open flannel shirt

    ## podcast-host | Podcast host | headshots
    look: polished podcast studio portrait for show artwork
    camera: 50mm lens, chest-up
    light: warm practical lamps and a soft key
    wear: a smart blazer over a plain tee
    - in a studio with acoustic foam panels and a boom-arm microphone | who: {subject} speaking into the microphone, mid-laugh
    - at a round table with two microphones and headphones | who: {subject} listening, headphones on
    - against a wall of warm wood slats with a neon accent strip | light: a cool rim light and warm key
    - in a cosy home studio with books and a plant behind | wear: a soft knit sweater
    - leaning back in a studio chair with headphones around the neck | who: {subject} with an easy smile
    - against a solid colour backdrop with a microphone in frame | camera: 85mm lens, head and shoulders | look: bold podcast cover portrait, clean background

    ## keynote-speaker | Keynote speaker | headshots
    look: conference photography, the speaker in the moment
    camera: 70-200mm lens from the audience, compressed background
    light: stage lighting with a warm key and cool wash behind
    wear: a dark blazer over a plain top
    - on a wide stage in front of a huge blank presentation screen | who: {subject} gesturing mid-sentence
    - at a lectern with a slim microphone | who: {subject} looking out over the audience
    - walking across the stage with a handheld microphone | camera: 35mm lens, low angle from the front row
    - seated in a panel discussion on a low stage | who: {subject} answering a question, hands open
    - backstage in the green room before the talk | light: warm mirror lights | camera: 50mm lens, candid
    - on stage in silhouette against the bright screen | who: {subject} with an arm raised | look: dramatic event photograph
    """
}
