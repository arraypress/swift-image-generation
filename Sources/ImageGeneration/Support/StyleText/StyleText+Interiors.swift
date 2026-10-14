//
//  StyleText+Interiors.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  Interior design styles: one style per look, each with a `{room}` slot
//  whose known values are the rooms and spaces below, so `japandi` makes a
//  kitchen, a hallway or a hotel lobby. A style says what makes the look —
//  palette, materials, furniture, light; the room says what is in the
//  space; the six shared views say where the camera stands, and the seed
//  walks them. Outdoor spaces (a garden, a house front) carry `#outdoors`:
//  they get six exterior views instead, and each style's `@outdoors`
//  wording — its materials and palette, outside, with no "interior". Written for this library; the format is described in
//  StyleCatalog.swift and the slot line in StyleSlots.swift.
//

extension StyleText {

    /// The rooms and spaces, as `name => phrase`. The first is the default.
    /// Every phrase carries its own article, so a value typed that is not
    /// listed ("wine cellar") reads as typed.
    static let interiorRooms = [
        "living room => a living room with a deep sofa, a pair of armchairs, a low coffee table and a large rug",
        "bedroom => a bedroom with a made-up double bed, bedside tables with lamps, a chest of drawers and a soft rug",
        "kitchen => a kitchen with fitted cabinets, a long worktop, an island with stools and a range cooker",
        "kitchen living combo => an open-plan kitchen and living area, an island with stools looking onto a sofa and a dining table",
        "bathroom => a bathroom with a freestanding tub, a walk-in shower, a vanity basin and a wall mirror",
        "dining room => a dining room with a long table, upholstered chairs, a sideboard and a pendant hung over the table",
        "kids room => a child's bedroom with a small bed, a play rug, toy storage and a reading nook",
        "study room => a study with a writing desk, a reading chair, full bookshelves and a desk lamp",
        "home office => a home office with a desk facing the window, an ergonomic chair, shelving and a monitor",
        "gaming room => a games room with a big screen, a sectional sofa, consoles on a low unit and a gaming desk",
        "walk in closet => a walk-in closet with open hanging rails, shoe shelves, drawers and a central island",
        "toilet => a small cloakroom toilet with a wall-hung basin, a compact toilet and a framed mirror",
        "laundry room => a laundry room with a washer and dryer under a worktop, a deep sink and a drying rail",
        "hallway => an entrance hallway with a console table, a mirror, a runner rug and coat hooks",
        "attic => an attic room under sloping ceilings with skylights, a daybed and low storage",
        "mudroom => a mudroom with a bench, cubbies for boots, coat hooks and a hard-wearing floor",
        "drop zone => a drop zone by the back door with a bench, baskets, shoe racks and key hooks",
        "gym => a home gym with a squat rack, a treadmill, a rubber floor and a mirrored wall",
        "garage gym => a garage turned into a gym, a power rack, free weights and rubber mats on concrete",
        "house exterior / house front / front of house / facade / exterior => the front of a house, its facade, entrance door, windows, roofline and front path #outdoors",
        "outdoor patio / patio / terrace / deck => an outdoor patio with lounge seating, a dining set, planters and an outdoor rug #outdoors",
        "outdoor garden / garden / back garden / backyard / yard => a back garden with planted borders, a lawn, a winding path, trees and a seating spot #outdoors",
        "outdoor pool area / pool / pool area / swimming pool => a pool terrace with sun loungers, a parasol, a paved deck and planting around the water #outdoors",
        "garage => a tidy garage with a parked car, wall-mounted storage, a workbench and a sealed concrete floor",
        "outdoor garage / detached garage => a detached garage seen from the driveway, its doors, wall lights and the planting around it #outdoors",
        "carport / driveway => a carport roofed on posts over a parked car, a paved driveway and planting alongside #outdoors",
        "front porch / porch / veranda => a front porch with steps up to the door, a pair of chairs, potted plants and a hanging lantern #outdoors",
        "balcony => a balcony with a railing, a small bistro set, planters and a view beyond #outdoors",
        "rooftop terrace / roof terrace / rooftop => a rooftop terrace with decking, lounge seating, tall planters and a skyline beyond #outdoors",
        "parking lot / car park => a small car park with marked bays, kerbs, lamp posts and planted edges #outdoors",
        "podcast studio => a podcast studio with a round table, two microphones on boom arms, headphones and acoustic panels",
        "photography studio => a photography studio with a paper backdrop, softboxes on stands and a styling rail",
        "movie set => a film set built as a room, lights on stands, a camera on a dolly and cables across the floor",
        "workshop => a workshop with a sturdy workbench, a pegboard of hand tools, storage drawers and task lights",
        "onsen => an indoor hot-spring bath with a stone soaking pool, wooden stools and a view onto a garden",
        "meeting room => a meeting room with a long table, a row of chairs, a wall screen and a whiteboard",
        "office => an office floor with rows of desks, task chairs, storage units and a breakout corner",
        "coworking space => a coworking space with shared tables, phone booths, lounge seating and a coffee point",
        "coffee shop => a coffee shop with a counter and espresso machine, small tables, stools and a pastry case",
        "restaurant => a restaurant dining room with laid tables, banquette seating, a bar and pendant lights",
        "store => a shop with display tables, wall shelving, a till counter and a feature window",
        "clothing store => a clothing boutique with garment rails, folded stacks, a fitting room and a long mirror",
        "hotel lobby => a hotel lobby with a reception desk, lounge seating, a statement light and a feature wall",
        "hotel room => a hotel bedroom with a large bed against a headboard wall, a desk, an armchair and heavy curtains",
        "hotel bathroom => a hotel bathroom with a double vanity, a rain shower, a deep tub and stacked towels",
        "exhibition space => an exhibition space with display plinths, partition walls, track lighting and open floor",
        "waiting room => a waiting room with rows of chairs, a low table, a reception counter and plants",
        "conference hall => a conference hall with a stage, a lectern, a projection screen and rows of seats",
        "press room => a press briefing room with a podium, a backdrop wall, rows of chairs and camera risers",
        "dance studio => a dance studio with a sprung wooden floor, a mirrored wall, a barre and a sound system",
        "board game cafe => a board game café with shelves of boxed games, square tables, chairs and a snack counter",
        "airport lounge => an airport lounge with armchairs, a buffet counter, work booths and windows onto the runway",
        "airplane cabin => an aircraft cabin with rows of seats, overhead bins, an aisle and oval windows",
        "lecture hall => a lecture hall with raked tiers of seats, a lectern, a long front desk and a large screen",
        "classroom => a classroom with rows of desks and chairs, a whiteboard, a teacher's desk and pinboards",
        "library => a library with tall bookcases, reading tables, study lamps and a quiet reading corner",
        "cafeteria => a cafeteria with a serving counter, long tables, stacking chairs and a drinks station",
        "church => a church interior with rows of pews, a central aisle, an altar and tall windows",
        "temple => a temple hall with an altar, cushions for sitting, lanterns and carved columns",
        "auditorium => an auditorium with tiered seating, a wide stage, curtains and a lighting rig",
        "cinema => a cinema with rows of reclining seats, a large screen, aisle lights and a projection window",
        "music stage => a music stage with a drum riser, amplifiers, microphone stands and a lighting truss",
        "concert hall => a concert hall with an orchestra platform, tiered seating, balconies and acoustic panels",
        "banquet hall => a banquet hall with round dressed tables, chairs, a top table and a dance floor",
        "ballroom => a ballroom with a polished dance floor, chandeliers, tall windows and seating around the edge",
        "museum hall => a museum hall with display cases, sculptures on plinths and benches",
        "gallery => an art gallery with white walls, framed works hung at eye level, track lights and a bench",
        "courtroom => a courtroom with a raised judge's bench, a witness stand, counsel tables and a public gallery",
        "parliament => a debating chamber with curved tiers of benches, a speaker's chair and an open central floor",
    ].joined(separator: "; ")

    /// Where the camera stands: the scenes every interior style shares. They
    /// set the lens and leave the light to the style.
    static let interiorViews = """
    - a wide view from the entrance with the whole space in frame | camera: 16mm wide-angle lens at eye level, verticals kept straight
    - a view from one corner with two sides of the space in frame | camera: 20mm lens, two-point perspective
    - a straight-on view of the main wall, centred and symmetrical | camera: 24mm lens, one-point perspective
    - a view from the far end looking back toward the entrance | camera: 18mm lens at chest height
    - a closer view of the main furniture and its textures | camera: 35mm lens, shallow depth of field
    - a raised view from above eye level that shows the layout | camera: 16mm lens tilted gently down
    """

    /// Where the camera stands outside: the scenes for a value tagged
    /// `#outdoors` (a garden, a house front), which replace the six above.
    static let exteriorViews = """
    - seen from the street or the approach with the whole place in frame | when: outdoors | camera: 24mm lens at eye level, verticals kept straight
    - seen across the lawn or the paving toward the building | when: outdoors | camera: 20mm lens, two-point perspective
    - from one corner of the plot with the boundary and planting in view | when: outdoors | camera: 18mm lens at chest height
    - at dusk with the lights on, glowing windows and lit paths | when: outdoors | light: blue-hour dusk with warm lamps glowing | camera: 24mm lens on a tripod
    - a closer view of the materials, planting and outdoor furniture | when: outdoors | camera: 50mm lens, shallow depth of field
    - a raised aerial view that shows the whole layout | when: outdoors | camera: drone view from above, angled gently down
    """

    /// The slot line every interior style declares.
    static let roomSlot = "slot: room = \(interiorRooms)"

    static let interiors = """
    ## modern | Modern | interiors
    look: modern interior design, interiors magazine photograph
    light: bright even daylight from large windows
    with: white and warm grey walls with one natural texture; streamlined low furniture on slim legs; wood, stone and linen in a restrained mix; a few chosen objects and nothing fussy
    look@outdoors: modern architecture and landscape design, architecture magazine photograph
    light@outdoors: bright clear daylight
    with@outdoors: white render, large glazing and warm timber cladding; clean-lined planters and a few sculptural plants; smooth stone paving; slim black metal outdoor furniture
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## minimalist | Minimalist | interiors
    look: minimalist interior design, interiors magazine photograph
    light: abundant soft daylight, almost shadowless
    with: a near-monochrome scheme with one accent colour; only essential pieces, each a strong simple form; bare surfaces and hidden storage; generous empty floor
    look@outdoors: minimalist architecture and landscape, architecture magazine photograph
    light@outdoors: soft even daylight
    with@outdoors: plain white or pale grey planes with no ornament; a single tree or one grass in a raised bed; large seamless paving slabs; nothing but the essentials
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## simple | Simple | interiors
    look: simple practical interior, interiors magazine photograph
    light: plain natural daylight
    with: neutral painted walls; plain useful furniture with no ornament; a tidy floor and clear surfaces; a calm, unfussy everyday feel
    look@outdoors: simple, practical house and garden, architecture magazine photograph
    light@outdoors: plain natural daylight
    with@outdoors: painted render or brick in neutral tones; a tidy lawn and neat borders; plain sturdy outdoor seating; uncluttered and easy to keep
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## contemporary | Contemporary | interiors
    look: contemporary interior design, interiors magazine photograph
    light: crisp daylight with recessed ceiling lights
    with: a neutral base set off by black and charcoal; sleek forms in smooth lacquer and brushed metal; glass tables and polished finishes; an open, airy layout
    look@outdoors: contemporary architecture and landscape, architecture magazine photograph
    light@outdoors: crisp daylight with discreet path lights
    with@outdoors: charcoal and white cladding with glass balustrades; sleek concrete planters and ornamental grasses; outdoor furniture on polished metal frames; strong clean contrasts
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## traditional | Traditional | interiors
    look: traditional interior design, interiors magazine photograph
    light: warm lamplight with soft window light
    with: wood panelling and crown mouldings; rolled-arm upholstered seating and turned-leg tables; damask and tartan in deep red, green and gold; furniture set symmetrically around a focal point; brass lamps and framed oil paintings
    look@outdoors: traditional house and garden, architecture magazine photograph
    light@outdoors: warm late-afternoon sun
    with@outdoors: red brick or painted clapboard with shuttered sash windows; box hedges and symmetrical urns; a brick or flagstone path; classic iron or teak benches
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## scandinavian | Scandinavian | interiors
    look: Scandinavian interior design, interiors magazine photograph
    light: pale northern daylight, soft and cool
    with: white walls and pale birch or ash floors; light-wood furniture on tapered legs; sheepskins, wool blankets and knitted cushions; a few green plants and candles for a cosy hygge mood
    look@outdoors: Scandinavian house and garden, architecture magazine photograph
    light@outdoors: pale northern daylight
    with@outdoors: white or black-stained timber cladding; a pale larch deck; birch trees, grasses and meadow planting; simple wooden outdoor furniture with wool throws and lanterns
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## japandi | Japandi | interiors
    look: Japandi interior design, interiors magazine photograph
    light: soft diffuse daylight
    with: Japanese restraint meeting Nordic warmth; low oak and ash furniture with rounded edges; linen, paper lanterns and handmade ceramics; warm greige, charcoal and muted clay
    look@outdoors: Japandi house and garden, architecture magazine photograph
    light@outdoors: soft diffuse daylight
    with@outdoors: pale and charred timber cladding; raked gravel, moss and stepping stones; a clipped maple and low pines; low oak benches and stone lanterns
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## guest-ready | Guest-ready rental | interiors
    look: welcoming holiday rental interior, listing photograph
    light: bright, friendly daylight
    with: durable neutral finishes with one piece of local craft; comfortable easy-care furniture and plenty of seating; light woods and plain linen; useful storage, fresh towels and a tidy, photo-ready finish
    look@outdoors: welcoming holiday rental exterior, listing photograph
    light@outdoors: bright, friendly daylight
    with@outdoors: freshly painted walls and a clear, inviting entrance; tidy planting and a swept terrace; comfortable outdoor seating for guests; string lights and potted herbs
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## french | French | interiors
    look: elegant French interior design, interiors magazine photograph
    light: soft daylight through tall French windows
    with: pale pastel walls with gilded mouldings; curvy carved furniture on cabriole legs; toile and silk upholstery; crystal sconces and an ornate mirror over a marble mantel
    look@outdoors: elegant French chateau-style exterior and formal garden, architecture magazine photograph
    light@outdoors: soft golden daylight
    with@outdoors: pale limestone with tall shuttered windows and wrought-iron balconies; clipped parterres and gravel walks; stone urns and a fountain; curly iron garden chairs
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## french-country | French country | interiors
    look: French country interior design, interiors magazine photograph
    light: warm afternoon sun
    with: rough plaster walls in warm cream; weathered painted wood and limewashed beams; a wrought-iron chandelier; sprigs of lavender, faded linens and antique farm pieces
    look@outdoors: French country farmhouse and garden, architecture magazine photograph
    light@outdoors: warm afternoon sun
    with@outdoors: rough stone walls with faded blue shutters; rows of lavender and climbing roses; a gravel courtyard; a weathered wooden table under a pergola
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## neoclassic | Neoclassic | interiors
    look: neoclassical interior design, interiors magazine photograph
    light: even, refined daylight from tall windows
    with: high ceilings with fluted pilasters and columns; strict symmetry with clear upright and level lines; restrained cream, stone and pale grey; Greek key borders, urns and classical busts; poised, timeless furniture
    look@outdoors: neoclassical facade and formal grounds, architecture magazine photograph
    light@outdoors: even, refined daylight
    with@outdoors: a symmetrical front with columns, a pediment and tall windows; pale stone and stucco; formal hedges, urns and statues; a straight axial path
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## retro | Retro | interiors
    look: retro interior design, interiors magazine photograph
    light: warm sunny daylight
    with: a fifties-to-seventies revival in orange, mustard and teal; moulded plastic chairs and chrome trim; bold geometric wallpaper; a shag rug and globe lamps
    look@outdoors: retro mid-century exterior, architecture magazine photograph
    light@outdoors: warm sunny daylight
    with@outdoors: a low-slung house with breeze-block screens; turquoise, orange and mustard accents; metal lawn chairs; desert and palm planting
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## modern-boho | Modern boho | interiors
    look: modern boho interior design, interiors magazine photograph
    light: warm diffuse daylight
    with: a calm sand, cream and terracotta palette; rattan and cane chairs beside clean-lined wood; jute rugs and linen and cotton throws; woven wall hangings, macramé and potted palms
    look@outdoors: modern boho house and garden, architecture magazine photograph
    light@outdoors: warm diffuse daylight
    with@outdoors: cream render and natural timber; terracotta pots, pampas grass and olive trees; rattan loungers and jute outdoor rugs; shade sails and lanterns
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## vintage | Vintage | interiors
    look: vintage interior design, interiors magazine photograph
    light: soft golden daylight
    with: pieces collected from several past decades; upcycled cabinets and a worn leather armchair; patterned rugs and colourful accents; old framed prints and an antique clock
    look@outdoors: vintage house and garden, architecture magazine photograph
    light@outdoors: soft golden daylight
    with@outdoors: an older house with painted woodwork and character; reclaimed garden furniture and galvanised watering cans; patterned tiles and colourful pots; a weathered bench and climbing plants
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## cottagecore | Cottagecore | interiors
    look: cottagecore interior, interiors magazine photograph
    light: gentle hazy morning light
    with: floral wallpaper and small-print fabrics; painted wooden furniture with chipped edges; dried flowers, baskets and handmade quilts; muted sage, cream and dusty rose
    look@outdoors: cottagecore cottage and garden, architecture magazine photograph
    light@outdoors: gentle hazy morning light
    with@outdoors: a small whitewashed or stone cottage with a mossy roof; overflowing beds of foxgloves and hollyhocks; a picket gate and a winding path; a wooden bench with a basket of flowers
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## hollywood-glam | Hollywood glam | interiors
    look: Hollywood Regency glamour interior, interiors magazine photograph
    light: dramatic glowing light from a crystal chandelier
    with: jewel-toned velvet upholstery; mirrored and lacquered surfaces trimmed in gold; tufted headboards and channel-stitched seats; a glossy black-and-white floor and plush faux fur
    look@outdoors: Hollywood Regency villa exterior, architecture magazine photograph
    light@outdoors: warm glamorous evening light
    with@outdoors: white stucco with black lacquered doors and gold fittings; a glossy pool edged in marble; striped cabanas and lounge chairs; clipped hedges and statement lanterns
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## parisian | Parisian | interiors
    look: Parisian apartment interior, interiors magazine photograph
    light: soft silvery daylight through tall windows
    with: herringbone parquet and elaborate plaster mouldings; a marble fireplace under an antique gilt mirror; flea-market antiques mixed with modern pieces; a soft neutral palette touched with black
    look@outdoors: Parisian townhouse exterior and courtyard, architecture magazine photograph
    light@outdoors: soft silvery daylight
    with@outdoors: cream limestone with wrought-iron balconies and tall windows; a cobbled courtyard with potted box balls; bistro chairs and a small marble table; climbing ivy
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## tropical | Tropical | interiors
    look: tropical interior design, interiors magazine photograph
    light: bright warm sun filtered through palm leaves
    with: rattan, wicker, bamboo and teak furniture; palm-leaf prints and cane panels; big potted palms and monstera; white walls with leafy green accents
    look@outdoors: tropical house and garden, architecture magazine photograph
    light@outdoors: bright warm sun filtered through palm leaves
    with@outdoors: white walls under deep timber eaves; lush palms, banana leaves and monstera; teak and rattan loungers; a stone path through dense green planting
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## baroque | Baroque | interiors
    look: baroque interior, interiors magazine photograph
    light: rich dramatic light with deep shadows
    with: gilded carving and heavy plaster ornament; massive carved furniture with twisted columns; crimson, gold and deep green damask and velvet; crystal chandeliers and towering mirrors
    look@outdoors: baroque palace facade and garden, architecture magazine photograph
    light@outdoors: rich dramatic light with long shadows
    with@outdoors: an ornate front with gilded details, carved stone and grand stairs; formal gardens with elaborate fountains and statues; hedges clipped in swirling patterns
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## bohemian | Bohemian | interiors
    look: bohemian interior, interiors magazine photograph
    light: warm low sun and strings of fairy lights
    with: layer upon layer of patterned rugs and textiles; mismatched furniture and floor cushions; saturated jewel colours; hanging plants, souvenirs from travels and woven baskets
    look@outdoors: bohemian house and garden, architecture magazine photograph
    light@outdoors: warm low sun and strings of fairy lights
    with@outdoors: colourful painted walls and mismatched pots; patterned rugs, floor cushions and a hammock outdoors; colourful fabric bunting and lanterns; wild, abundant planting
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## mediterranean | Mediterranean | interiors
    look: Mediterranean interior design, interiors magazine photograph
    light: bright sun-drenched light
    with: terracotta floor tiles and whitewashed walls; rounded arches and alcoves; wrought-iron fittings and rough stone; blue-and-white patterned tiles and olive trees in pots
    look@outdoors: Mediterranean villa and garden, architecture magazine photograph
    light@outdoors: bright sun-drenched light
    with@outdoors: whitewashed walls, terracotta roof tiles and arched openings; bougainvillea, olive and lemon trees in pots; blue painted shutters and patterned tiles; a shaded pergola over a long table
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## medieval | Medieval | interiors
    look: medieval castle interior, interiors magazine photograph
    light: flickering candlelight and torchlight with dim window light
    with: rough stone walls and dark timber beams; heavy carved oak tables, chairs and benches; tapestries and fabrics in deep red, gold and blue; iron candelabra and heraldic shields
    look@outdoors: medieval stone house or castle exterior, cinematic photograph
    light@outdoors: soft overcast light with torchlight at the door
    with@outdoors: rough stone walls, small deep windows and heavy oak doors; timber beams under slate or thatch; a cobbled yard with iron fittings; heraldic shields on the gate
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## luxury | Luxury | interiors
    look: luxury interior design, interiors magazine photograph
    light: warm layered light from designer fixtures
    with: book-matched marble and polished stone; bespoke furniture in fine leather and silk; rich textures and precious-metal accents; a calm, lavish, perfectly finished space
    look@outdoors: luxury villa exterior and grounds, architecture magazine photograph
    light@outdoors: warm golden-hour light
    with@outdoors: flawless stone and glass with bespoke detailing; an infinity pool and manicured planting; designer outdoor sofas and fire bowls; precise landscape lighting
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## japanese-design | Japanese design | interiors
    look: traditional Japanese interior, interiors magazine photograph
    light: soft light diffused through shoji screens
    with: tatami mats and sliding paper doors; low wooden furniture close to the floor; bamboo and pale cypress wood; an alcove holding a single flower arrangement; quiet wabi-sabi imperfection
    look@outdoors: traditional Japanese house and garden, architecture magazine photograph
    light@outdoors: soft even daylight
    with@outdoors: dark timber, deep eaves and sliding screens; a raked gravel garden, moss and a koi pond; stone lanterns and clipped pines; a wooden veranda
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## bali-interior | Bali | interiors
    look: Balinese boho interior, interiors magazine photograph
    light: warm ambient light and soft tropical daylight
    with: cream or chalk-white walls over microcement floors; teak and oak furniture with rattan chairs; low-slung modular seating, woven pendants and seagrass rugs; glass doors open to lush palms; arched niches in the walls
    look@outdoors: Balinese villa and tropical garden, architecture magazine photograph
    light@outdoors: warm tropical light
    with@outdoors: a thatched timber pavilion and pale stone walls; a pool among frangipani and palms; carved teak doors and stone statues; rattan daybeds and woven lamps
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## sketch | Sketch | interiors
    look: architect's hand-drawn sketch in black ink on white paper, no colour
    light: shadows suggested with light pen hatching
    with: loose, confident pen lines; walls and furniture drawn in outline; perspective construction lines left visible
    look@outdoors: architect's hand-drawn sketch of the building and landscape in black ink on white paper, no colour
    light@outdoors: shadows suggested with light pen hatching
    with@outdoors: loose, confident pen lines; the building, trees and paving drawn in outline; perspective construction lines left visible
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## easter-interior | Easter | interiors
    look: spring holiday interior, interiors magazine photograph
    light: fresh spring daylight
    with: pastel blue, yellow and mint accents; painted eggs in bowls and a spring wreath; tulips and daffodils in vases on the table; bunny figurines and soft linen
    look@outdoors: spring holiday exterior, magazine photograph
    light@outdoors: fresh spring daylight
    with@outdoors: pastel bunting and a spring wreath on the door; tulips and daffodils in pots and beds; painted eggs hidden in the grass; blossom on the trees
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## coastal | Coastal | interiors
    look: coastal interior design, interiors magazine photograph
    light: breezy bright seaside light
    with: white and pale blue with sandy beige; whitewashed wood, wicker and linen slipcovers; driftwood and sea-glass accents; a relaxed beach-house ease
    look@outdoors: coastal beach house exterior, architecture magazine photograph
    light@outdoors: breezy bright seaside light
    with@outdoors: white weatherboard with pale blue trim; a sun-bleached deck among dune grasses; wicker and teak outdoor chairs; a sandy path toward the sea
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## cyberpunk-interior | Cyberpunk | interiors
    look: cyberpunk interior, cinematic photograph
    light: magenta and cyan neon glow at night with city lights through the window
    with: dark surfaces and hard angular geometry; LED strips along every edge; chrome, black glass and exposed cables; holographic screens and synth-era gadgets; a gritty high-tech mood
    look@outdoors: cyberpunk exterior, cinematic photograph
    light@outdoors: magenta and cyan neon glow at night, reflected in wet surfaces
    with@outdoors: dark concrete and metal in hard angular forms; LED strips along every edge and glowing screens; cables, vents and chrome; rain and haze in the air
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## midcentury-modern | Midcentury modern | interiors
    look: mid-century modern interior, interiors magazine photograph
    light: warm daylight from wide windows
    with: teak and walnut furniture on tapered legs; organic curves beside graphic shapes; muted olive, mustard and burnt orange; a sputnik chandelier; indoor plants that bring the garden in
    look@outdoors: mid-century modern house and garden, architecture magazine photograph
    light@outdoors: warm daylight
    with@outdoors: a low flat-roofed house with walls of glass and timber; breeze-block screens and a carport; teak loungers and a kidney-shaped pool; desert plants and palms
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## maximalist | Maximalist | interiors
    look: maximalist interior, interiors magazine photograph
    light: rich warm lamplight
    with: clashing bold patterns on walls, rugs and upholstery; saturated colour everywhere; crowded gallery walls and stacked books; collections on every surface
    look@outdoors: maximalist house and garden, magazine photograph
    light@outdoors: rich warm afternoon light
    with@outdoors: boldly painted walls and patterned tiles; crowded planting in clashing colours; layered outdoor rugs, cushions and lanterns; sculptures and collections everywhere
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## eco-friendly | Eco-friendly | interiors
    look: sustainable interior design, interiors magazine photograph
    light: plentiful natural daylight
    with: reclaimed timber and bamboo furniture; organic cotton, hemp and wool textiles; cork floors and natural plaster; recycled glass and living plants
    look@outdoors: sustainable house and garden, architecture magazine photograph
    light@outdoors: plentiful natural daylight
    with@outdoors: timber cladding, a green roof and solar panels; rainwater butts and wildflower planting; reclaimed wood furniture; vegetable beds and a compost corner
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## farmhouse | Farmhouse | interiors
    look: modern farmhouse interior, interiors magazine photograph
    light: warm soft daylight
    with: white shiplap walls and exposed wood beams; a sliding barn door; open shelves of stoneware; a scrubbed pine table, old finds and black iron accents
    look@outdoors: modern farmhouse exterior, architecture magazine photograph
    light@outdoors: warm soft daylight
    with@outdoors: white board-and-batten siding and a black metal roof; a wide porch with rocking chairs; barn-style lights and a gravel drive; a picket fence and raised vegetable beds
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## boho-chic | Boho-chic | interiors
    look: boho-chic interior, interiors magazine photograph
    light: warm golden light
    with: layered rugs, throws and tasselled cushions; earthy rust and ochre with cream; vintage finds and pieces from far away; rattan, carved wood and art in a relaxed, styled mix
    look@outdoors: boho-chic house and garden, magazine photograph
    light@outdoors: warm golden light
    with@outdoors: warm ochre and cream walls; rattan chairs, layered outdoor rugs and tasselled cushions; terracotta pots, palms and pampas grass; lanterns and fabric canopies
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## shabby-chic | Shabby chic | interiors
    look: shabby chic interior, interiors magazine photograph
    light: soft romantic daylight through lace curtains
    with: distressed white-painted furniture; faded florals and pastel linens; antique lace and ruffles; chipped old mirrors and roses in jugs
    look@outdoors: shabby chic cottage and garden, magazine photograph
    light@outdoors: soft romantic daylight
    with@outdoors: white-painted, gently weathered woodwork; climbing roses and pastel flowers; a distressed iron bench and chipped enamel jugs of flowers; a lace cloth on a garden table
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## rustic | Rustic | interiors
    look: rustic interior, interiors magazine photograph
    light: warm firelight and low sun
    with: raw timber beams and rough-hewn wood; stone walls and a stone hearth; iron hardware and woven baskets; earthy browns and cosy wool throws
    look@outdoors: rustic house and grounds, architecture magazine photograph
    light@outdoors: warm low sun
    with@outdoors: rough-hewn timber and fieldstone walls; a wide wooden porch; log benches and iron lanterns; wild grasses and a woodpile
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## retro-futuristic | Retro futuristic | interiors
    look: retro-futuristic interior, the future as imagined in the 1960s, interiors magazine photograph
    light: bright even light from glowing ceiling discs
    with: rounded white pod furniture and curved walls; polished marble and smoked glass; chrome details and pops of orange
    look@outdoors: retro-futuristic exterior, the future as imagined in the 1960s, magazine photograph
    light@outdoors: bright even daylight
    with@outdoors: rounded white forms and curved walls on slender legs; smoked glass and chrome; neat lawns with sculptural plants; pops of orange
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## industrial | Industrial | interiors
    look: industrial loft interior, interiors magazine photograph
    light: cool daylight from big steel-framed windows
    with: exposed brick and raw concrete; visible ducts, pipes and steel beams; reclaimed wood and black metal furniture; bare filament bulbs and a converted-factory feel
    look@outdoors: industrial building exterior, architecture magazine photograph
    light@outdoors: cool daylight
    with@outdoors: exposed brick, raw concrete and steel-framed windows; corrugated metal and black steel; reclaimed wood benches; gravel and hardy planting in steel troughs
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## hot-pink | Hot pink | interiors
    look: hot pink interior, playful glossy photograph
    light: bright glossy light
    with: hot pink and fuchsia on walls and upholstery; glossy lacquered and moulded plastic furniture; glitter, sparkle and pink velvet; a playful dollhouse glamour
    look@outdoors: hot pink exterior, playful glossy photograph
    light@outdoors: bright sunny light
    with@outdoors: hot pink and fuchsia walls and doors; glossy pink outdoor furniture and a pink pool float; palms and pink flowers; a playful dollhouse glamour
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## eclectic | Eclectic | interiors
    look: eclectic interior design, interiors magazine photograph
    light: warm mixed daylight and lamplight
    with: pieces from different eras and countries side by side; bold unexpected colour pairings; one-off art and old finds; layered textures with a personal point of view
    look@outdoors: eclectic house and garden, magazine photograph
    light@outdoors: warm mixed daylight
    with@outdoors: a mix of eras in the building and its furniture; bold colour pairings on doors and walls; one-off sculptures and planters; layered, personal details
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## surf-shack | Surf shack | interiors
    look: surf shack interior, interiors magazine photograph
    light: salty late-afternoon sun
    with: weathered boards and driftwood furniture; surfboards on the walls; sea-blue and sand textiles; rope, nets, shells and a hammock
    look@outdoors: surf shack exterior, magazine photograph
    light@outdoors: salty late-afternoon sun
    with@outdoors: weathered timber boards and a tin roof; surfboards leaning by the door; a hammock, rope and driftwood; sand, dune grass and an outdoor shower
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## biophilic | Biophilic | interiors
    look: biophilic interior design, interiors magazine photograph
    light: dappled sunlight
    with: plants at every level, a living wall and trailing greenery; wood, cork, bamboo and clay; organic shapes and patterns taken from nature; earthy greens and browns, fresh and calm
    look@outdoors: biophilic architecture and landscape, architecture magazine photograph
    light@outdoors: dappled sunlight
    with@outdoors: green walls and planted roofs; timber, stone and clay; organic curving forms; dense layered planting that merges with the building
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## art-nouveau | Art nouveau | interiors
    look: Art Nouveau interior, interiors magazine photograph
    light: soft amber light through coloured glass
    with: whiplash curves and plant-like ironwork; stained-glass panels and mosaic tiles; flowing arched doorways and furniture; muted sage, mauve and ash tones; stylised lilies and peacock feathers
    look@outdoors: Art Nouveau facade and garden, architecture magazine photograph
    light@outdoors: soft warm daylight
    with@outdoors: flowing curved stonework and plant-like ironwork; stained-glass windows and mosaic details; arched doorways; sage, mauve and ash tones
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## art-deco | Art deco | interiors
    look: Art Deco interior, interiors magazine photograph
    light: glamorous light from frosted-glass fixtures
    with: bold geometry, sunbursts and chevrons; lacquer, brass and polished veneers; rich emerald, black and gold; symmetrical streamlined furniture with stepped forms
    look@outdoors: Art Deco building exterior, architecture magazine photograph
    light@outdoors: glamorous evening light
    with@outdoors: a stepped front with bold geometric relief; sunbursts, chevrons and polished brass; cream, black and emerald; streamlined curved corners
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## global-artisan | Global artisan | interiors
    look: global artisan interior with handcrafted pieces, interiors magazine photograph
    light: warm desert-toned daylight
    with: hand-dyed batik and mud-cloth textiles; woven grass baskets and wall plates; carved wooden stools and sculpture; worn timber and stone floors; terracotta, ochre and sand with bright splashes
    look@outdoors: global artisan house and garden, magazine photograph
    light@outdoors: warm desert-toned daylight
    with@outdoors: earthen render walls and carved wooden doors; woven grass shades and baskets; handmade pots and sculpture; terracotta, ochre and sand with bright splashes
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## ski-chalet | Ski chalet | interiors
    look: alpine ski chalet interior, interiors magazine photograph
    light: warm fire glow with snowy daylight at the window
    with: log walls and heavy timber beams; a big stone fireplace; sheepskins, furs and patterned wool blankets; antlers and carved wood details
    look@outdoors: alpine ski chalet exterior, architecture magazine photograph
    light@outdoors: crisp snowy daylight with warm windows
    with@outdoors: log and timber walls under a steep snow-covered roof; carved wooden balconies; stacked firewood and skis by the door; pine trees in deep snow
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## vaporwave | Vaporwave | interiors
    look: vaporwave interior, dreamy retro-digital photograph
    light: pink and purple neon haze
    with: pastel pink, baby blue and teal; white square tiles and classical white busts; palm plants and chrome; an eighties shopping-mall dreaminess
    look@outdoors: vaporwave exterior, dreamy retro-digital photograph
    light@outdoors: pink and purple neon haze
    with@outdoors: pastel pink, baby blue and teal surfaces; white classical busts and columns; palm trees and chrome; a glowing pool
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## futuristic | Futuristic | interiors
    look: futuristic interior, interiors magazine photograph
    light: cool even light from hidden coves
    with: smooth white surfaces with seamless curves; floating built-ins and circular forms; polished marble, glass and brushed steel; a monochrome scheme with one bright accent
    look@outdoors: futuristic architecture and landscape, architecture magazine photograph
    light@outdoors: cool even daylight
    with@outdoors: smooth white seamless curves and cantilevered forms; polished glass and brushed steel; sculpted landscaping; a monochrome scheme with one bright accent
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## halloween-interior | Halloween | interiors
    look: Halloween party interior, interiors magazine photograph
    light: orange glow of carved pumpkins and candles
    with: jack-o'-lanterns and stacked pumpkins; cobwebs in the corners and plastic spiders; black and orange decorations; skeletons and old lanterns for a spooky party
    look@outdoors: Halloween exterior, magazine photograph
    light@outdoors: orange glow of carved pumpkins at dusk
    with@outdoors: jack-o'-lanterns on the steps and path; cobwebs across the porch and windows; skeletons and gravestone props in the garden; black and orange decorations and old lanterns
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## christmas-interior | Christmas | interiors
    look: Christmas interior, interiors magazine photograph
    light: warm twinkling fairy lights and firelight
    with: a decorated tree with wrapped presents beneath; garlands of greenery, berries and pine cones; stockings hung by the fireplace; tartan throws and snow falling past the window
    look@outdoors: Christmas exterior, magazine photograph
    light@outdoors: warm twinkling lights in the evening
    with@outdoors: lights along the roofline and in the trees; a wreath on the front door; garlands and red ribbons; a snowy garden with a lit tree
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## lunar-new-year-interior | Lunar New Year | interiors
    look: Lunar New Year interior, interiors magazine photograph
    light: warm red lantern glow
    with: red paper lanterns and knotted tassels; red and gold cushions and table runners; potted kumquat trees and plum blossom; paper-cut decorations and bowls of mandarins
    look@outdoors: Lunar New Year exterior, magazine photograph
    light@outdoors: warm red lantern glow
    with@outdoors: red paper lanterns along the eaves and the path; red and gold decorations on the door; potted kumquat trees and plum blossom; paper-cut decorations in the windows
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## gaming-den | Gaming den | interiors
    look: gaming setup interior, moody photograph
    light: a dark room lit by purple, red and blue LEDs
    with: a desk with several monitors, a keyboard and speakers; a racing-style gaming chair; consoles and controllers; dark walls with neon light strips
    look@outdoors: gaming den exterior at night, moody photograph
    light@outdoors: night lit by purple, red and blue LEDs
    with@outdoors: a dark building outlined in LED strips; a glowing window with screens inside; neon light strips along the paths; a sleek modern outdoor lounge
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## nautical | Nautical | interiors
    look: nautical interior, interiors magazine photograph
    light: crisp sea light
    with: navy and crisp white stripes; weathered wood and brass fittings; rope, anchors and model ships; porthole mirrors
    look@outdoors: nautical seaside exterior, magazine photograph
    light@outdoors: crisp sea light
    with@outdoors: white boards with navy trim and stripes; rope railings and brass lanterns; an anchor and life rings; a deck facing the water
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## gothic | Gothic | interiors
    look: gothic interior, interiors magazine photograph
    light: candlelight in a dim, moody room
    with: pointed arches and tall leaded windows; dark stone and black-stained wood; heavy carved furniture; deep burgundy and black velvet; wrought-iron candelabra
    look@outdoors: gothic exterior, cinematic photograph
    light@outdoors: moody dusk light with candle glow
    with@outdoors: dark stone with pointed arches and tall leaded windows; wrought-iron gates and fences; overgrown ivy and dark planting; gargoyles and lanterns
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## post-apocalyptic | Post-apocalyptic | interiors
    look: post-apocalyptic interior, cinematic photograph
    light: grey dusty light through broken windows
    with: abandoned and weathered, peeling paint and rust; makeshift furniture from scavenged parts; tarps, crates and patched fabric; debris and creeping weeds
    look@outdoors: post-apocalyptic exterior, cinematic photograph
    light@outdoors: grey dusty light
    with@outdoors: abandoned and weathered, peeling paint and rust; makeshift shelters from scavenged parts; tarps, crates and wrecked cars; weeds through cracked paving
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## soviet | Soviet | interiors
    look: Soviet-era interior, documentary photograph
    light: flat, cold fluorescent light
    with: austere utilitarian furniture; raw concrete on a monumental scale; lacquered wall units and patterned carpets; institutional greens and browns; heavy brutalist forms
    look@outdoors: Soviet-era exterior, documentary photograph
    light@outdoors: flat overcast light
    with@outdoors: raw concrete blocks on a monumental scale; rows of identical windows and balconies; worn courtyard benches and climbing frames; patchy grass and birch trees
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)

    ## zen | Zen | interiors
    look: zen interior, interiors magazine photograph
    light: calm soft daylight
    with: a nearly empty, serene space; low simple furniture in natural wood; stone, paper and linen; a bonsai or a single branch in a vase; muted sand and stone tones
    look@outdoors: zen garden and house, architecture magazine photograph
    light@outdoors: calm soft daylight
    with@outdoors: a raked gravel garden with a few rocks; moss, a clipped pine and a stone water basin; low timber decks; muted sand and stone tones
    who: {room}
    \(roomSlot)
    \(interiorViews)
    \(exteriorViews)
    """
}
