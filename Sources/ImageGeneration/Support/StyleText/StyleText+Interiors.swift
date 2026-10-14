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
//  walks them. Written for this library; the format is described in
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
        "house exterior => the front of a house, its facade, entrance door, windows, roofline and front path",
        "outdoor patio => an outdoor patio with lounge seating, a dining set, planters and an outdoor rug",
        "outdoor garden => a back garden with planted borders, a lawn, a winding path, trees and a seating spot",
        "outdoor pool area => a pool terrace with sun loungers, a parasol, a paved deck and planting around the water",
        "garage => a tidy garage with a parked car, wall-mounted storage, a workbench and a sealed concrete floor",
        "outdoor garage => a detached garage seen from the driveway, its doors, wall lights and the planting around it",
        "carport => a carport roofed on posts over a parked car, a paved driveway and planting alongside",
        "parking lot => a small car park with marked bays, kerbs, lamp posts and planted edges",
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

    /// The slot line every interior style declares.
    static let roomSlot = "slot: room = \(interiorRooms)"

    static let interiors = """
    ## modern | Modern | interiors
    look: modern interior design, interiors magazine photograph
    light: bright even daylight from large windows
    with: white and warm grey walls with one natural texture; streamlined low furniture on slim legs; wood, stone and linen in a restrained mix; a few chosen objects and nothing fussy
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## minimalist | Minimalist | interiors
    look: minimalist interior design, interiors magazine photograph
    light: abundant soft daylight, almost shadowless
    with: a near-monochrome scheme with one accent colour; only essential pieces, each a strong simple form; bare surfaces and hidden storage; generous empty floor
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## simple | Simple | interiors
    look: simple practical interior, interiors magazine photograph
    light: plain natural daylight
    with: neutral painted walls; plain useful furniture with no ornament; a tidy floor and clear surfaces; a calm, unfussy everyday feel
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## contemporary | Contemporary | interiors
    look: contemporary interior design, interiors magazine photograph
    light: crisp daylight with recessed ceiling lights
    with: a neutral base set off by black and charcoal; sleek forms in smooth lacquer and brushed metal; glass tables and polished finishes; an open, airy layout
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## traditional | Traditional | interiors
    look: traditional interior design, interiors magazine photograph
    light: warm lamplight with soft window light
    with: wood panelling and crown mouldings; rolled-arm upholstered seating and turned-leg tables; damask and tartan in deep red, green and gold; furniture set symmetrically around a focal point; brass lamps and framed oil paintings
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## scandinavian | Scandinavian | interiors
    look: Scandinavian interior design, interiors magazine photograph
    light: pale northern daylight, soft and cool
    with: white walls and pale birch or ash floors; light-wood furniture on tapered legs; sheepskins, wool blankets and knitted cushions; a few green plants and candles for a cosy hygge mood
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## japandi | Japandi | interiors
    look: Japandi interior design, interiors magazine photograph
    light: soft diffuse daylight
    with: Japanese restraint meeting Nordic warmth; low oak and ash furniture with rounded edges; linen, paper lanterns and handmade ceramics; warm greige, charcoal and muted clay
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## guest-ready | Guest-ready rental | interiors
    look: welcoming holiday rental interior, listing photograph
    light: bright, friendly daylight
    with: durable neutral finishes with one piece of local craft; comfortable easy-care furniture and plenty of seating; light woods and plain linen; useful storage, fresh towels and a tidy, photo-ready finish
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## french | French | interiors
    look: elegant French interior design, interiors magazine photograph
    light: soft daylight through tall French windows
    with: pale pastel walls with gilded mouldings; curvy carved furniture on cabriole legs; toile and silk upholstery; crystal sconces and an ornate mirror over a marble mantel
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## french-country | French country | interiors
    look: French country interior design, interiors magazine photograph
    light: warm afternoon sun
    with: rough plaster walls in warm cream; weathered painted wood and limewashed beams; a wrought-iron chandelier; sprigs of lavender, faded linens and antique farm pieces
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## neoclassic | Neoclassic | interiors
    look: neoclassical interior design, interiors magazine photograph
    light: even, refined daylight from tall windows
    with: high ceilings with fluted pilasters and columns; strict symmetry with clear upright and level lines; restrained cream, stone and pale grey; Greek key borders, urns and classical busts; poised, timeless furniture
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## retro | Retro | interiors
    look: retro interior design, interiors magazine photograph
    light: warm sunny daylight
    with: a fifties-to-seventies revival in orange, mustard and teal; moulded plastic chairs and chrome trim; bold geometric wallpaper; a shag rug and globe lamps
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## modern-boho | Modern boho | interiors
    look: modern boho interior design, interiors magazine photograph
    light: warm diffuse daylight
    with: a calm sand, cream and terracotta palette; rattan and cane chairs beside clean-lined wood; jute rugs and linen and cotton throws; woven wall hangings, macramé and potted palms
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## vintage | Vintage | interiors
    look: vintage interior design, interiors magazine photograph
    light: soft golden daylight
    with: pieces collected from several past decades; upcycled cabinets and a worn leather armchair; patterned rugs and colourful accents; old framed prints and an antique clock
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## cottagecore | Cottagecore | interiors
    look: cottagecore interior, interiors magazine photograph
    light: gentle hazy morning light
    with: floral wallpaper and small-print fabrics; painted wooden furniture with chipped edges; dried flowers, baskets and handmade quilts; muted sage, cream and dusty rose
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## hollywood-glam | Hollywood glam | interiors
    look: Hollywood Regency glamour interior, interiors magazine photograph
    light: dramatic glowing light from a crystal chandelier
    with: jewel-toned velvet upholstery; mirrored and lacquered surfaces trimmed in gold; tufted headboards and channel-stitched seats; a glossy black-and-white floor and plush faux fur
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## parisian | Parisian | interiors
    look: Parisian apartment interior, interiors magazine photograph
    light: soft silvery daylight through tall windows
    with: herringbone parquet and elaborate plaster mouldings; a marble fireplace under an antique gilt mirror; flea-market antiques mixed with modern pieces; a soft neutral palette touched with black
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## tropical | Tropical | interiors
    look: tropical interior design, interiors magazine photograph
    light: bright warm sun filtered through palm leaves
    with: rattan, wicker, bamboo and teak furniture; palm-leaf prints and cane panels; big potted palms and monstera; white walls with leafy green accents
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## baroque | Baroque | interiors
    look: baroque interior, interiors magazine photograph
    light: rich dramatic light with deep shadows
    with: gilded carving and heavy plaster ornament; massive carved furniture with twisted columns; crimson, gold and deep green damask and velvet; crystal chandeliers and towering mirrors
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## bohemian | Bohemian | interiors
    look: bohemian interior, interiors magazine photograph
    light: warm low sun and strings of fairy lights
    with: layer upon layer of patterned rugs and textiles; mismatched furniture and floor cushions; saturated jewel colours; hanging plants, souvenirs from travels and woven baskets
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## mediterranean | Mediterranean | interiors
    look: Mediterranean interior design, interiors magazine photograph
    light: bright sun-drenched light
    with: terracotta floor tiles and whitewashed walls; rounded arches and alcoves; wrought-iron fittings and rough stone; blue-and-white patterned tiles and olive trees in pots
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## medieval | Medieval | interiors
    look: medieval castle interior, interiors magazine photograph
    light: flickering candlelight and torchlight with dim window light
    with: rough stone walls and dark timber beams; heavy carved oak tables, chairs and benches; tapestries and fabrics in deep red, gold and blue; iron candelabra and heraldic shields
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## luxury | Luxury | interiors
    look: luxury interior design, interiors magazine photograph
    light: warm layered light from designer fixtures
    with: book-matched marble and polished stone; bespoke furniture in fine leather and silk; rich textures and precious-metal accents; a calm, lavish, perfectly finished space
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## japanese-design | Japanese design | interiors
    look: traditional Japanese interior, interiors magazine photograph
    light: soft light diffused through shoji screens
    with: tatami mats and sliding paper doors; low wooden furniture close to the floor; bamboo and pale cypress wood; an alcove holding a single flower arrangement; quiet wabi-sabi imperfection
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## bali-interior | Bali | interiors
    look: Balinese boho interior, interiors magazine photograph
    light: warm ambient light and soft tropical daylight
    with: cream or chalk-white walls over microcement floors; teak and oak furniture with rattan chairs; low-slung modular seating, woven pendants and seagrass rugs; glass doors open to lush palms; arched niches in the walls
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## sketch | Sketch | interiors
    look: architect's hand-drawn sketch in black ink on white paper, no colour
    light: shadows suggested with light pen hatching
    with: loose, confident pen lines; walls and furniture drawn in outline; perspective construction lines left visible
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## easter-interior | Easter | interiors
    look: spring holiday interior, interiors magazine photograph
    light: fresh spring daylight
    with: pastel blue, yellow and mint accents; painted eggs in bowls and a spring wreath; tulips and daffodils in vases on the table; bunny figurines and soft linen
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## coastal | Coastal | interiors
    look: coastal interior design, interiors magazine photograph
    light: breezy bright seaside light
    with: white and pale blue with sandy beige; whitewashed wood, wicker and linen slipcovers; driftwood and sea-glass accents; a relaxed beach-house ease
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## cyberpunk-interior | Cyberpunk | interiors
    look: cyberpunk interior, cinematic photograph
    light: magenta and cyan neon glow at night with city lights through the window
    with: dark surfaces and hard angular geometry; LED strips along every edge; chrome, black glass and exposed cables; holographic screens and synth-era gadgets; a gritty high-tech mood
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## midcentury-modern | Midcentury modern | interiors
    look: mid-century modern interior, interiors magazine photograph
    light: warm daylight from wide windows
    with: teak and walnut furniture on tapered legs; organic curves beside graphic shapes; muted olive, mustard and burnt orange; a sputnik chandelier; indoor plants that bring the garden in
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## maximalist | Maximalist | interiors
    look: maximalist interior, interiors magazine photograph
    light: rich warm lamplight
    with: clashing bold patterns on walls, rugs and upholstery; saturated colour everywhere; crowded gallery walls and stacked books; collections on every surface
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## eco-friendly | Eco-friendly | interiors
    look: sustainable interior design, interiors magazine photograph
    light: plentiful natural daylight
    with: reclaimed timber and bamboo furniture; organic cotton, hemp and wool textiles; cork floors and natural plaster; recycled glass and living plants
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## farmhouse | Farmhouse | interiors
    look: modern farmhouse interior, interiors magazine photograph
    light: warm soft daylight
    with: white shiplap walls and exposed wood beams; a sliding barn door; open shelves of stoneware; a scrubbed pine table, old finds and black iron accents
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## boho-chic | Boho-chic | interiors
    look: boho-chic interior, interiors magazine photograph
    light: warm golden light
    with: layered rugs, throws and tasselled cushions; earthy rust and ochre with cream; vintage finds and pieces from far away; rattan, carved wood and art in a relaxed, styled mix
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## shabby-chic | Shabby chic | interiors
    look: shabby chic interior, interiors magazine photograph
    light: soft romantic daylight through lace curtains
    with: distressed white-painted furniture; faded florals and pastel linens; antique lace and ruffles; chipped old mirrors and roses in jugs
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## rustic | Rustic | interiors
    look: rustic interior, interiors magazine photograph
    light: warm firelight and low sun
    with: raw timber beams and rough-hewn wood; stone walls and a stone hearth; iron hardware and woven baskets; earthy browns and cosy wool throws
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## retro-futuristic | Retro futuristic | interiors
    look: retro-futuristic interior, the future as imagined in the 1960s, interiors magazine photograph
    light: bright even light from glowing ceiling discs
    with: rounded white pod furniture and curved walls; polished marble and smoked glass; chrome details and pops of orange
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## industrial | Industrial | interiors
    look: industrial loft interior, interiors magazine photograph
    light: cool daylight from big steel-framed windows
    with: exposed brick and raw concrete; visible ducts, pipes and steel beams; reclaimed wood and black metal furniture; bare filament bulbs and a converted-factory feel
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## hot-pink | Hot pink | interiors
    look: hot pink interior, playful glossy photograph
    light: bright glossy light
    with: hot pink and fuchsia on walls and upholstery; glossy lacquered and moulded plastic furniture; glitter, sparkle and pink velvet; a playful dollhouse glamour
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## eclectic | Eclectic | interiors
    look: eclectic interior design, interiors magazine photograph
    light: warm mixed daylight and lamplight
    with: pieces from different eras and countries side by side; bold unexpected colour pairings; one-off art and old finds; layered textures with a personal point of view
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## surf-shack | Surf shack | interiors
    look: surf shack interior, interiors magazine photograph
    light: salty late-afternoon sun
    with: weathered boards and driftwood furniture; surfboards on the walls; sea-blue and sand textiles; rope, nets, shells and a hammock
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## biophilic | Biophilic | interiors
    look: biophilic interior design, interiors magazine photograph
    light: dappled sunlight
    with: plants at every level, a living wall and trailing greenery; wood, cork, bamboo and clay; organic shapes and patterns taken from nature; earthy greens and browns, fresh and calm
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## art-nouveau | Art nouveau | interiors
    look: Art Nouveau interior, interiors magazine photograph
    light: soft amber light through coloured glass
    with: whiplash curves and plant-like ironwork; stained-glass panels and mosaic tiles; flowing arched doorways and furniture; muted sage, mauve and ash tones; stylised lilies and peacock feathers
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## art-deco | Art deco | interiors
    look: Art Deco interior, interiors magazine photograph
    light: glamorous light from frosted-glass fixtures
    with: bold geometry, sunbursts and chevrons; lacquer, brass and polished veneers; rich emerald, black and gold; symmetrical streamlined furniture with stepped forms
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## global-artisan | Global artisan | interiors
    look: global artisan interior with handcrafted pieces, interiors magazine photograph
    light: warm desert-toned daylight
    with: hand-dyed batik and mud-cloth textiles; woven grass baskets and wall plates; carved wooden stools and sculpture; worn timber and stone floors; terracotta, ochre and sand with bright splashes
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## ski-chalet | Ski chalet | interiors
    look: alpine ski chalet interior, interiors magazine photograph
    light: warm fire glow with snowy daylight at the window
    with: log walls and heavy timber beams; a big stone fireplace; sheepskins, furs and patterned wool blankets; antlers and carved wood details
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## vaporwave | Vaporwave | interiors
    look: vaporwave interior, dreamy retro-digital photograph
    light: pink and purple neon haze
    with: pastel pink, baby blue and teal; white square tiles and classical white busts; palm plants and chrome; an eighties shopping-mall dreaminess
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## futuristic | Futuristic | interiors
    look: futuristic interior, interiors magazine photograph
    light: cool even light from hidden coves
    with: smooth white surfaces with seamless curves; floating built-ins and circular forms; polished marble, glass and brushed steel; a monochrome scheme with one bright accent
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## halloween-interior | Halloween | interiors
    look: Halloween party interior, interiors magazine photograph
    light: orange glow of carved pumpkins and candles
    with: jack-o'-lanterns and stacked pumpkins; cobwebs in the corners and plastic spiders; black and orange decorations; skeletons and old lanterns for a spooky party
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## christmas-interior | Christmas | interiors
    look: Christmas interior, interiors magazine photograph
    light: warm twinkling fairy lights and firelight
    with: a decorated tree with wrapped presents beneath; garlands of greenery, berries and pine cones; stockings hung by the fireplace; tartan throws and snow falling past the window
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## lunar-new-year-interior | Lunar New Year | interiors
    look: Lunar New Year interior, interiors magazine photograph
    light: warm red lantern glow
    with: red paper lanterns and knotted tassels; red and gold cushions and table runners; potted kumquat trees and plum blossom; paper-cut decorations and bowls of mandarins
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## gaming-den | Gaming den | interiors
    look: gaming setup interior, moody photograph
    light: a dark room lit by purple, red and blue LEDs
    with: a desk with several monitors, a keyboard and speakers; a racing-style gaming chair; consoles and controllers; dark walls with neon light strips
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## nautical | Nautical | interiors
    look: nautical interior, interiors magazine photograph
    light: crisp sea light
    with: navy and crisp white stripes; weathered wood and brass fittings; rope, anchors and model ships; porthole mirrors
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## gothic | Gothic | interiors
    look: gothic interior, interiors magazine photograph
    light: candlelight in a dim, moody room
    with: pointed arches and tall leaded windows; dark stone and black-stained wood; heavy carved furniture; deep burgundy and black velvet; wrought-iron candelabra
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## post-apocalyptic | Post-apocalyptic | interiors
    look: post-apocalyptic interior, cinematic photograph
    light: grey dusty light through broken windows
    with: abandoned and weathered, peeling paint and rust; makeshift furniture from scavenged parts; tarps, crates and patched fabric; debris and creeping weeds
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## soviet | Soviet | interiors
    look: Soviet-era interior, documentary photograph
    light: flat, cold fluorescent light
    with: austere utilitarian furniture; raw concrete on a monumental scale; lacquered wall units and patterned carpets; institutional greens and browns; heavy brutalist forms
    who: {room}
    \(roomSlot)
    \(interiorViews)

    ## zen | Zen | interiors
    look: zen interior, interiors magazine photograph
    light: calm soft daylight
    with: a nearly empty, serene space; low simple furniture in natural wood; stone, paper and linen; a bonsai or a single branch in a vase; muted sand and stone tones
    who: {room}
    \(roomSlot)
    \(interiorViews)
    """
}
