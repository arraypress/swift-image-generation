//
//  StyleText+Retro.swift
//  ImageGeneration
//
//  Created by David Sherlock on 2026.
//
//  Decades: the clothes, rooms and film stock of each. Written for this
//  library; the format is described in StyleCatalog.swift.
//

extension StyleText {

    static let retro = """
    ## silent-film | Silent film | retro
    look: 1920s silent-film still, black and white, soft vignette, flicker grain
    camera: fixed studio camera, theatrical framing
    light: hard arc-lamp light
    - in a grand hotel lobby with potted palms | wear: a beaded flapper dress and a cloche hat / a beaded flapper dress, headband and long pearls / a three-piece suit and a boater
    - on a steam train platform waving goodbye | wear: a travelling coat and hat
    - on a theatre stage taking a dramatic bow | who: {subject} with exaggerated expression
    - at a speakeasy bar with a jazz band | light: smoky and dim
    - leaning out of an open-top roadster | camera: tracking shot feel, background blurred
    - on a film set with a director's megaphone nearby | look: behind-the-scenes photograph of a 1920s film set

    ## film-noir | Film noir | retro
    look: 1940s–50s film noir still, black and white, deep shadows
    camera: 35mm lens, low angle, tilted
    light: hard light through venetian blinds
    wear: a belted trench coat and a fedora / a fitted skirt suit, gloves and a small hat / a trench coat, fedora and a loosened tie
    - in a detective's office with rain on the window | who: {subject} lighting a match
    - under a lone street lamp on a wet street | light: a single pool of light in darkness
    - in a vintage train compartment, gazing out | light: passing light flickering across the face
    - on a staircase with long shadows | camera: high angle
    - in a phone booth at night | light: the booth's bare bulb
    - at a smoky nightclub with a singer blurred behind | light: spotlight haze

    ## fifties-diner | 1950s diner | retro
    look: 1950s colour photograph, saturated slide-film colour
    camera: 50mm lens
    light: bright, cheerful daylight
    wear: a polka-dot swing dress and a neck scarf / a polka-dot swing dress, a neck scarf and victory rolls / a short-sleeve bowling shirt and rolled jeans
    - in a red vinyl booth with a milkshake and two straws | who: {subject} smiling over the glass
    - at the counter with a stack of pancakes and a coffee | light: sun through the windows
    - beside a jukebox | who: {subject} choosing a record
    - outside by a two-tone car | light: sunny afternoon
    - on roller skates carrying a tray | camera: full figure, motion
    - at a drive-in at dusk | light: dusk and the neon sign

    ## sixties-mod | 1960s | retro
    look: 1960s colour photograph, bold graphic colours
    camera: 50mm lens
    light: flat, bright 1960s studio light
    wear: a shift dress with go-go boots / a geometric shift dress, go-go boots and winged liner / a slim mod suit and Chelsea boots
    - in a living room with a sunken conversation pit | who: {subject} on the phone with a curly cord
    - on a scooter on a London street | light: overcast city light
    - at a psychedelic party with liquid light projections | light: swirling coloured projections
    - in front of a pop-art backdrop of dots | look: graphic pop-art photograph
    - by a hi-fi console with a stack of records | light: warm lamp light
    - on a beach in a 1960s holiday camp | wear: retro swimwear and a sun hat

    ## seventies | 1970s | retro
    look: 1970s photograph, warm faded colours, soft grain
    camera: 50mm lens
    light: warm, hazy light
    wear: a peasant blouse, flared jeans and beads / a peasant blouse, flared jeans and a headscarf / a wide-collar shirt, flared trousers and a suede jacket
    - on an orange shag carpet sorting vinyl records | who: {subject} holding up an album
    - at a roller disco under a mirror ball | light: mirror-ball sparkles
    - beside a camper van in a canyon | light: golden hour
    - in a wood-panelled den with a lava lamp | light: lamp glow
    - at a summer festival in a field | who: {subject} with a flower in their hair
    - on a disco dance floor in a sequinned jumpsuit | wear: a sequinned jumpsuit | light: coloured floor lights

    ## eighties | 1980s | retro
    look: 1980s photograph, saturated colour, flash, film grain
    camera: 35mm lens
    light: on-camera flash
    wear: an oversized blazer with shoulder pads and big hair / a neon windbreaker and leg warmers / a pastel suit with rolled sleeves
    - in a bedroom covered in band posters with a cassette player | who: {subject} holding a mixtape
    - in an arcade full of glowing cabinets | light: neon arcade light
    - at an aerobics class in leotards and leg warmers | wear: a bright leotard and leg warmers
    - leaning on a sports car on a palm-lined boulevard | light: sunset
    - in a mall food court | light: bright fluorescent
    - with a boombox on a city stoop | camera: low angle

    ## nineties | 1990s | retro
    look: 1990s photograph, slightly washed-out film, point-and-shoot flash
    camera: compact film camera
    light: direct flash
    wear: a patterned knit sweater and high-waisted jeans / a white tee layered under a slip dress / a flannel shirt, baggy jeans and a backwards cap
    - at a desk with a beige computer and a dial-up modem | who: {subject} looking up from the chunky monitor
    - in a bedroom with glow-in-the-dark stars and a CD tower | light: lamp and flash
    - at a video rental shop holding two tapes | light: fluorescent shop light
    - on a skate ramp at a park | camera: fisheye lens
    - at a house party in a kitchen | light: flash
    - in a photo-booth style portrait | look: grainy photo-booth print

    ## y2k | Y2K | retro
    look: early-2000s digital camera photograph, glossy and slightly overexposed
    camera: compact digital camera with flash
    light: direct flash
    wear: a metallic halter top, low-rise jeans and platform shoes / a metallic halter top, low-rise jeans and butterfly clips / a baggy tracksuit and tinted sunglasses
    - at a club under strobe lights | light: strobe and flash
    - in a bedroom with an inflatable chair | who: {subject} on a flip phone
    - at a mall with frosted lip gloss | light: bright mall light
    - in front of a silver tinsel curtain | look: glossy party photograph
    - with a chunky silver laptop and headphones | light: screen glow
    - on a city street with a mini handbag | light: hazy sun
    """

    static let seasonal = """
    ## halloween | Halloween | seasonal
    look: playful Halloween photograph, spooky and atmospheric
    camera: 35mm lens
    light: candlelight and glowing pumpkins
    - in a vintage witch costume beside a cauldron | wear: a witch's hat and a long black cloak
    - in a field of pumpkins under a full moon | light: moonlight and lantern glow | wear: a cosy orange knit
    - as a vampire in a gothic candlelit hall | wear: a high-collared black cape
    - as a skeleton with painted face at a party | wear: a skeleton bodysuit and painted face
    - carving a jack-o'-lantern at a kitchen table | light: warm glow from the pumpkin
    - in a foggy cemetery at dusk | wear: a long dark coat | light: blue fog
    - in a red devil costume with horns among pumpkins and cobwebs | wear: a red devil costume with small horns

    ## christmas | Christmas | seasonal
    look: cosy Christmas photograph, warm and festive
    camera: 50mm lens
    light: warm fairy lights and firelight
    wear: a festive knitted jumper
    - beside a decorated tree with wrapped gifts | who: {subject} holding a glowing bauble
    - by a fireplace with stockings hung | light: firelight
    - on a snowy street of a Christmas market | light: market stall lights | wear: a wool coat and scarf
    - baking gingerbread in a warm kitchen | who: {subject} with flour on their cheek
    - in a Santa suit with a sack of gifts | wear: a red Santa suit and white beard
    - walking through a snowy forest with a freshly cut tree | light: soft snowy daylight
    - wrapped in blankets with hot chocolate by a frosted window | light: candlelight

    ## easter | Easter | seasonal
    look: fresh springtime photograph, pastel and bright
    camera: 50mm lens
    light: soft spring sunlight
    wear: a pastel spring outfit
    - in a blooming garden with a basket of painted eggs | who: {subject} smiling
    - on an Easter egg hunt in long grass | camera: 35mm lens, full figure
    - at a brunch table with hot cross buns and tulips | light: bright window light
    - painting eggs at a kitchen table | camera: close, hands and eggs
    - in a field of daffodils | light: fresh morning sun
    - with a soft white rabbit in their arms | camera: 85mm lens

    ## valentines | Valentine's Day | seasonal
    look: sweet romantic photograph, red and pink
    camera: 50mm lens
    light: soft warm light
    wear: a pink knit sweater
    - clutching a heart balloon among vases of red roses | who: {subject} smiling
    - at a candlelit dinner with chocolates | light: candlelight
    - in a flower shop with an armful of roses | light: shop window light
    - writing a card at a desk with petals around | camera: close-up
    - on a city street at dusk with a gift box | wear: a red coat
    - in bed with a breakfast tray of strawberries | light: soft morning light

    ## new-years-eve | New Year's Eve | seasonal
    look: celebratory party photograph, sparkling
    camera: 35mm lens
    light: sparklers and warm party light
    wear: a gold sequinned outfit
    - surrounded by falling confetti at midnight | who: {subject} cheering with a glass raised
    - on a rooftop with fireworks over a city | light: fireworks bursting
    - holding a sparkler at a party | camera: slow shutter, light trails
    - at a bar with a champagne tower | light: glittering
    - on a balcony under a starry sky | wear: a velvet evening outfit
    - in front of a wall of gold balloons | look: glossy party photograph

    ## diwali | Diwali | seasonal
    look: warm festive photograph, glowing and joyful
    camera: 50mm lens
    light: warm diya and string light glow
    wear: festive silk / a silk lehenga with gold jewellery / a silk kurta
    - lighting rows of clay diyas on steps | who: {subject} smiling
    - making a colourful rangoli pattern | camera: overhead view
    - with sparklers on a terrace at night | light: sparklers and city lights
    - by a doorway of marigold garlands | light: warm evening light
    - sharing sweets from a decorated box | camera: close-up
    - on a rooftop with lanterns floating up | light: lantern glow

    ## holi | Holi | seasonal
    look: vivid festival photograph, clouds of colour
    camera: 35mm lens, fast shutter
    light: bright daylight
    wear: a white outfit splashed with colour
    - throwing a handful of pink powder | who: {subject} laughing
    - in a cloud of yellow and green powder | camera: 1/1000 s
    - with colour-streaked face, close-up | camera: 85mm lens
    - in a crowded street festival | camera: 24mm lens
    - under a spray of coloured water | light: backlit spray
    - dancing to drums | camera: motion blur

    ## eid | Eid | seasonal
    look: joyful festive photograph, warm and elegant
    camera: 50mm lens
    light: lantern and fairy light glow
    wear: an elegant modest festive outfit / an embroidered abaya with a silk hijab / an embroidered kurta and cap
    - by a table set with dates, sweets and tea | who: {subject} smiling
    - under hanging brass lanterns | light: patterned lantern light
    - with a crescent moon over the city at dusk | light: blue hour
    - with henna on the hands, close-up | camera: 100mm lens
    - at a family gathering in a courtyard | camera: 35mm lens
    - by a window decorated with lights | light: warm fairy lights

    ## hanukkah | Hanukkah | seasonal
    look: warm festive home photograph
    camera: 50mm lens
    light: candlelight
    wear: a cosy blue knit sweater
    - lighting the menorah at a window | who: {subject} with a candle
    - at a table with latkes and doughnuts | light: warm lamp light
    - spinning a dreidel on the table | camera: close-up
    - with a gathering of family around the candles | camera: 35mm lens
    - wrapping gifts in blue and silver | light: soft lamp light
    - by a frosted window at night | light: menorah glow

    ## day-of-the-dead | Day of the Dead | seasonal
    look: vibrant festival photograph, marigold colour
    camera: 50mm lens
    light: candlelight
    wear: festive embroidered clothes and flowers
    - with sugar-skull face paint and a crown of flowers | camera: 85mm lens
    - beside an ofrenda of photos, marigolds and candles | light: candle glow
    - in a parade with papel picado overhead | light: festive daylight
    - in a cemetery decorated with marigolds at night | light: candles
    - holding a bouquet of marigolds | camera: close-up
    - at a family table with pan de muerto | light: warm lamps

    ## lunar-new-year | Lunar New Year | seasonal
    look: festive photograph, red and gold
    camera: 50mm lens
    light: red lantern glow
    wear: a silk outfit with gold embroidery / a silk qipao with gold embroidery / a silk tang jacket
    - under rows of red lanterns | who: {subject} holding a paper fan
    - at a family dinner with dumplings | light: warm overhead light
    - watching a lion dance in the street | camera: 35mm lens
    - holding a red envelope | camera: close-up
    - with fireworks over a city | light: fireworks
    - in a flower market with blossoms | light: daylight
    """
}
