-- source is from Keldon AI github. Using this instead of making my own database to reduce risk of errors from data entry
cardtxt = [[
# cards.txt
#
# N:card name
# T:type:cost:vp
#   Type is 1: world, 2: development
# E@e0:n0@e1:n1[...]
#   Number of this card introduced at each expansion level
# G:goodtype
#   Only valid for worlds, and optional there
# F:flags
#   START world, MILITARY, WINDFALL, REBEL, ALIEN, IMPERIUM, etc
# P:phase:code:value:times
#   Times is only relevant for certain consume powers
# V:value:type:name
#   Extra victory points for 6-cost developments

# Action cards

N:Explore (+5)
T:0:0:0
E@0:1
F:ACTION_CARD
P:1:DRAW:5:0

N:Explore (+1,+1)
T:0:0:0
E@0:1
F:ACTION_CARD
P:1:DRAW:1:0
P:1:KEEP:1:0

N:Develop
T:0:0:0
E@0:1
F:ACTION_CARD
P:2:REDUCE:1:0

N:Settle
T:0:0:0
E@0:1
F:ACTION_CARD
P:3:DRAW_AFTER:1:0

N:Consume ($)
T:0:0:0
E@0:1
F:ACTION_CARD
P:4:TRADE_ACTION:0:0

N:Consume (x2)
T:0:0:0
E@0:1
F:ACTION_CARD
P:4:DOUBLE_VP:0:0

N:Produce
T:0:0:0
E@0:1
F:ACTION_CARD
P:5:WINDFALL_ANY:0:0

#
# Promo home worlds
#

N:Gateway Station
T:1:2:1
E@0:1
#E:1:1:1:1:1
G:NOVELTY
F:PROMO | START | START_BLUE | WINDFALL
P:4:CONSUME_ANY | CONSUME_TWO | GET_3_CARD | GET_VP:1:1

N:Abandoned Mine Squatters
T:1:2:0
E@0:1
#E:1:1:1:1:1
G:RARE
F:PROMO | START | START_RED | MILITARY
P:3:EXTRA_MILITARY:1:0
P:5:PRODUCE:0:0

N:Terraforming Colonists
T:1:2:1
E@0:1
#E:1:1:1:1:1
F:PROMO | START | START_BLUE | TERRAFORMING
P:3:DRAW_AFTER:1:0
P:5:DISCARD_HAND | WINDFALL_ANY:1:0

N:Galactic Trade Emissaries
T:1:2:1
E@0:1
#E:1:1:1:1:1
F:PROMO | START | START_RED
P:3:PAY_MILITARY:1:0
P:4:DRAW:1:0

N:Industrial Robots
T:1:2:1
E@0:1
#E:1:1:1:1:1
F:PROMO | START | START_BLUE
P:2:DRAW_AFTER:1:0
P:5:DRAW:1:0

N:Star Nomad Raiders
T:1:2:1
E@0:1
#E:1:1:1:1:1
F:PROMO | START | START_RED | MILITARY
P:3:EXTRA_MILITARY:1:0
P:4:TRADE_ANY:2:0

#
# Base game
#

N:Old Earth
T:1:3:2
E@0:1
#E:1:1:1:1:1
F:START | START_BLUE
P:4:TRADE_ANY:1:0
P:4:CONSUME_ANY | GET_VP:1:2

N:Epsilon Eridani
T:1:2:1
E@0:1
#E:1:1:1:1:1
F:START | START_RED
P:3:EXTRA_MILITARY:1:0
P:4:CONSUME_ANY | GET_CARD | GET_VP:1:1

N:Alpha Centauri
T:1:2:0
E@0:1
#E:1:1:1:1:1
G:RARE
F:START | START_BLUE | WINDFALL
P:3:REDUCE | RARE:1:0
P:3:BONUS_MILITARY | RARE:1:0

N:New Sparta
T:1:2:1
E@0:1
#E:1:1:1:1:1
F:START | START_RED | MILITARY
P:3:EXTRA_MILITARY:2:0

N:Earth's Lost Colony
T:1:2:1
E@0:1
#E:1:1:1:1:1
G:NOVELTY
F:START | START_BLUE
P:4:CONSUME_ANY | GET_VP:1:1
P:5:PRODUCE:0:0

N:Rebel Fuel Cache
T:1:1:1
E@0:1
#E:1:1:1:1:1
G:RARE
F:WINDFALL | MILITARY | REBEL

N:Public Works
T:2:1:1
E@0:2
#E:2:2:2:2:2
P:2:DRAW_AFTER:1:0
P:4:CONSUME_ANY | GET_VP:1:1

N:Gem World
T:1:2:1
E@0:1
#E:1:1:1:1:1
G:NOVELTY
P:5:PRODUCE:0:0
P:5:DRAW_IF:1:0

N:Colony Ship
T:2:2:1
E@0:2
#E:2:2:2:2:2
P:3:DISCARD | REDUCE_ZERO:0:0

N:Comet Zone
T:1:3:2
E@0:1
#E:1:1:1:1:1
G:RARE
P:5:PRODUCE:0:0
P:5:DRAW_IF:1:0

N:Expedition Force
T:2:1:1
E@0:2
#E:2:2:2:2:2
P:1:DRAW:1:0
P:3:EXTRA_MILITARY:1:0

N:Mining Robots
T:2:2:1
E@0:2
#E:2:2:2:2:2
P:3:REDUCE | RARE:1:0
P:5:WINDFALL_RARE:0:0

N:Rebel Miners
T:1:2:1
E@0:1
#E:1:1:1:1:1
G:RARE
F:MILITARY | REBEL
P:5:PRODUCE:0:0

N:Export Duties
T:2:1:1
E@0:2
#E:2:2:2:2:2
P:4:TRADE_ANY:1:0

N:Former Penal Colony
T:1:2:1
E@0:1
#E:1:1:1:1:1
G:NOVELTY
F:WINDFALL | MILITARY
P:3:EXTRA_MILITARY:1:0

N:Malevolent Lifeforms
T:1:4:2
E@0:1
#E:1:1:1:1:1
G:GENE
F:MILITARY
P:1:DRAW:1:0
P:5:PRODUCE:0:0

N:New Military Tactics
T:2:1:1
E@0:2
#E:2:2:2:2:2
P:3:DISCARD | EXTRA_MILITARY:3:0

N:Space Marines
T:2:2:1
E@0:2
#E:2:2:2:2:2
P:3:EXTRA_MILITARY:2:0

N:Contact Specialist
T:2:1:1
E@0:2@1:1
#E:2:3:3:3:2
P:3:EXTRA_MILITARY:-1:0
P:3:PAY_MILITARY:1:0

N:Avian Uplift Race
T:1:2:2
E@0:1
#E:1:1:1:1:1
G:GENE
F:WINDFALL | MILITARY | UPLIFT | CHROMO

N:Spice World
T:1:2:1
E@0:1
#E:1:1:1:1:1
G:NOVELTY
P:4:TRADE_NOVELTY:2:0
P:5:PRODUCE:0:0

N:Lost Species Ark World
T:1:5:3
E@0:1
#E:1:1:1:1:1
G:GENE
P:5:PRODUCE:0:0
P:5:DRAW_IF:2:0

N:New Vinland
T:1:2:1
E@0:1
#E:1:1:1:1:1
G:NOVELTY
P:4:CONSUME_ANY | GET_2_CARD:1:1
P:5:PRODUCE:0:0

N:Artist Colony
T:1:1:1
E@0:1
#E:1:1:1:1:1
G:NOVELTY
P:5:PRODUCE:0:0

N:Alien Robotic Factory
T:1:6:5
E@0:1
#E:1:1:1:1:1
G:ALIEN
F:ALIEN
P:5:PRODUCE:0:0

N:Plague World
T:1:3:0
E@0:1
#E:1:1:1:1:1
G:GENE
P:4:CONSUME_GENE | GET_CARD | GET_VP:1:1
P:5:PRODUCE:0:0

N:Distant World
T:1:4:2
E@0:1
#E:1:1:1:1:1
G:GENE
P:4:TRADE_NOVELTY:3:0
P:5:PRODUCE:0:0

N:Rebel Outpost
T:1:5:5
E@0:1
#E:1:1:1:1:1
F:REBEL | MILITARY
P:3:EXTRA_MILITARY:1:0

N:Rebel Warrior Race
T:1:3:2
E@0:1
#E:1:1:1:1:1
G:GENE
F:REBEL | WINDFALL | MILITARY
P:3:EXTRA_MILITARY:1:0

N:Rebel Underground
T:1:3:4
E@0:1
#E:1:1:1:1:1
F:REBEL | MILITARY
P:5:DRAW:1:0

N:New Survivalists
T:1:1:1
E@0:1
#E:1:1:1:1:1
G:NOVELTY
F:MILITARY
P:4:CONSUME_NOVELTY | GET_CARD:1:1
P:5:PRODUCE:0:0

N:Outlaw World
T:1:1:1
E@0:1
#E:1:1:1:1:1
F:MILITARY
P:3:EXTRA_MILITARY:1:0
P:4:CONSUME_ANY | GET_CARD | GET_VP:1:1

N:Lost Alien Battle Fleet
T:1:6:4
E@0:1
#E:1:1:1:1:1
G:ALIEN
F:ALIEN | MILITARY
P:3:EXTRA_MILITARY:3:0
P:5:PRODUCE:0:0

N:Diversified Economy
T:2:4:2
E@0:2
#E:2:2:2:2:2
P:4:CONSUME_3_DIFF | GET_VP:3:1
P:5:DRAW_DIFFERENT:1:0

N:Consumer Markets
T:2:5:3
E@0:2
#E:2:2:2:2:2
P:4:CONSUME_NOVELTY | GET_VP:1:3
P:5:DRAW_EACH_NOVELTY:1:0

N:Mining Conglomerate
T:2:3:2
E@0:2
#E:2:2:2:2:2
P:4:TRADE_RARE:1:0
P:4:CONSUME_RARE | GET_VP:1:2
P:5:DRAW_MOST_RARE:2:0

N:Research Labs
T:2:4:2
E@0:2@2:1
#E:2:2:3:3:2
P:1:KEEP:1:0
P:4:CONSUME_GENE | GET_VP:1:1
P:5:DRAW_EACH_ALIEN:1:0

N:Deficit Spending
T:2:2:1
E@0:2
#E:2:2:2:2:2
P:4:DISCARD_HAND | GET_VP:1:2

N:Investment Credits
T:2:1:1
E@0:2
#E:2:2:2:2:2
P:2:REDUCE:1:0

N:Pan-Galactic League
T:2:6:0
E@0:1
#E:1:1:1:1:1
P:3:EXTRA_MILITARY:-1:0
P:5:DRAW_WORLD_GENE:1:0
V:2:GENE_PRODUCTION:N/A
V:2:GENE_WINDFALL:N/A
V:1:MILITARY:N/A
V:3:NAME:Contact Specialist

N:Mining League
T:2:6:0
E@0:1
#E:1:1:1:1:1
P:4:CONSUME_RARE | CONSUME_TWO | GET_VP:3:1
P:5:WINDFALL_RARE:0:0
V:2:RARE_PRODUCTION:N/A
V:1:RARE_WINDFALL:N/A
V:2:NAME:Mining Robots
V:2:NAME:Mining Conglomerate

N:Free Trade Association
T:2:6:0
E@0:1
#E:1:1:1:1:1
P:4:CONSUME_NOVELTY | GET_CARD | GET_VP:1:3
P:5:WINDFALL_NOVELTY:0:0
V:2:NOVELTY_PRODUCTION:N/A
V:1:NOVELTY_WINDFALL:N/A
V:2:NAME:Consumer Markets
V:2:NAME:Expanding Colony

N:Alien Tech Institute
T:2:6:0
E@0:1
#E:1:1:1:1:1
F:ALIEN
P:3:REDUCE | ALIEN:2:0
P:3:BONUS_MILITARY | ALIEN:2:0
V:3:ALIEN_PRODUCTION:N/A
V:2:ALIEN_WINDFALL:N/A
V:2:ALIEN_FLAG:N/A

N:Galactic Survey: SETI
T:2:6:0
E@0:1
#E:1:1:1:1:1
P:1:DRAW:2:0
V:1:DEVEL_EXPLORE:N/A
V:2:WORLD_EXPLORE:N/A
V:1:WORLD:N/A

N:Galactic Federation
T:2:6:0
E@0:1
#E:1:1:1:1:1
P:2:REDUCE:2:0
V:2:SIX_DEVEL:N/A
V:1:DEVEL:N/A

N:Refugee World
T:1:0:1
E@0:1
#E:1:1:1:1:1
G:NOVELTY
F:WINDFALL
P:3:EXTRA_MILITARY:-1:0

N:Empath World
T:1:1:1
E@0:1
#E:1:1:1:1:1
G:GENE
F:WINDFALL
P:3:EXTRA_MILITARY:-1:0

N:Galactic Resort
T:1:3:2
E@0:1
#E:1:1:1:1:1
G:NOVELTY
F:WINDFALL
P:4:CONSUME_ANY | GET_CARD | GET_VP:1:1

N:Pre-Sentient Race
T:1:2:1
E@0:1
#E:1:1:1:1:1
G:GENE
F:WINDFALL

N:Deserted Alien Outpost
T:1:4:3
E@0:1
#E:1:1:1:1:1
G:ALIEN
F:ALIEN | WINDFALL

N:Deserted Alien Colony
T:1:5:4
E@0:1
#E:1:1:1:1:1
G:ALIEN
F:ALIEN | WINDFALL

N:Galactic Engineers
T:1:2:1
E@0:1
#E:1:1:1:1:1
P:4:TRADE_ANY:1:0
P:5:WINDFALL_ANY:0:0

N:Black Market Trading World
T:1:2:1
E@0:1
#E:1:1:1:1:1
P:4:TRADE_ACTION | TRADE_NO_BONUS:0:0

N:Merchant World
T:1:4:2
E@0:1
#E:1:1:1:1:1
P:4:TRADE_ANY:2:0
P:4:DISCARD_HAND | GET_VP:1:2

N:Tourist World
T:1:4:2
E@0:1
#E:1:1:1:1:1
P:4:CONSUME_ANY | CONSUME_TWO | GET_VP:3:1

N:Galactic Trendsetters
T:1:5:3
E@0:1
#E:1:1:1:1:1
P:4:CONSUME_ANY | GET_VP:2:1

N:Alien Rosetta Stone World
T:1:3:3
E@0:1
#E:1:1:1:1:1
F:ALIEN
P:3:REDUCE | ALIEN:2:0
P:3:BONUS_MILITARY | ALIEN:2:0
P:5:WINDFALL_ALIEN:0:0

N:Star Nomad Lair
T:1:1:1
E@0:1
#E:1:1:1:1:1
G:NOVELTY
F:WINDFALL | MILITARY
P:1:DRAW:1:0
P:4:TRADE_THIS:1:0

N:The Last of the Uplift Gnarssh
T:1:1:0
E@0:1
#E:1:1:1:1:1
G:GENE
F:WINDFALL | MILITARY | UPLIFT | CHROMO

N:Alien Robot Sentry
T:1:2:2
E@0:1
#E:1:1:1:1:1
G:ALIEN
F:WINDFALL | MILITARY | ALIEN

N:Pirate World
T:1:3:2
E@0:1
#E:1:1:1:1:1
G:NOVELTY
F:WINDFALL | MILITARY
P:4:TRADE_THIS:3:0

N:Reptilian Uplift Race
T:1:2:2
E@0:1
#E:1:1:1:1:1
G:GENE
F:WINDFALL | MILITARY | UPLIFT | CHROMO

N:Lost Alien Warship
T:1:5:3
E@0:1
#E:1:1:1:1:1
G:ALIEN
F:WINDFALL | MILITARY | ALIEN
P:3:EXTRA_MILITARY:2:0

N:Alien Robot Scout Ship
T:1:4:2
E@0:1
#E:1:1:1:1:1
G:ALIEN
F:WINDFALL | MILITARY | ALIEN
P:3:EXTRA_MILITARY:1:0

N:Runaway Robots
T:1:1:1
E@0:1
#E:1:1:1:1:1
G:RARE
F:WINDFALL | MILITARY
P:5:DRAW_IF:1:0

N:Interstellar Bank
T:2:2:1
E@0:2
#E:2:2:2:2:2
P:2:DRAW:1:0

N:Terraforming Robots
T:2:3:2
E@0:2
#E:2:2:2:2:2
F:TERRAFORMING
P:3:DRAW_AFTER:1:0
P:4:CONSUME_RARE | GET_CARD | GET_VP:1:1

N:Drop Ships
T:2:4:2
E@0:2
#E:2:2:2:2:2
P:3:EXTRA_MILITARY:3:0

N:New Galactic Order
T:2:6:0
E@0:1
#E:1:1:1:1:1
P:3:EXTRA_MILITARY:2:0
V:1:TOTAL_MILITARY:N/A

N:Asteroid Belt
T:1:2:1
E@0:1
#E:1:1:1:1:1
G:RARE
F:WINDFALL

N:Merchant Guild
T:2:6:0
E@0:1
#E:1:1:1:1:1
P:5:DRAW:2:0
V:2:NOVELTY_PRODUCTION:N/A
V:2:RARE_PRODUCTION:N/A
V:2:GENE_PRODUCTION:N/A
V:2:ALIEN_PRODUCTION:N/A
V:1:GOODS_REMAINING:N/A

N:Secluded World
T:1:1:1
E@0:1
#E:1:1:1:1:1
G:NOVELTY
P:4:CONSUME_ANY | GET_CARD:1:1
P:5:PRODUCE:0:0

N:Imperium Armaments World
T:1:3:2
E@0:1
#E:1:1:1:1:1
G:RARE
F:IMPERIUM
P:3:EXTRA_MILITARY:1:0
P:5:PRODUCE:0:0

N:Terraformed World
T:1:5:5
E@0:1
#E:1:1:1:1:1
P:4:CONSUME_ANY | GET_VP:1:1

N:Replicant Robots
T:2:4:2
E@0:2
#E:2:2:2:2:2
P:3:REDUCE:2:0

N:Pilgrimage World
T:1:0:2
E@0:1
#E:1:1:1:1:1
P:4:CONSUME_ALL | GET_VP:1:1

N:Rebel Homeworld
T:1:7:7
E@0:1
#E:1:1:1:1:1
F:MILITARY | REBEL

N:New Economy
T:2:6:0
E@0:1
#E:1:1:1:1:1
P:4:DRAW:1:0
V:2:DEVEL_CONSUME:N/A
V:1:WORLD_CONSUME:N/A

N:Radioactive World
T:1:2:1
E@0:1
#E:1:1:1:1:1
G:RARE
F:WINDFALL

N:Aquatic Uplift Race
T:1:2:2
E@0:1
#E:1:1:1:1:1
G:GENE
F:WINDFALL | MILITARY | UPLIFT | CHROMO

N:Genetics Lab
T:2:2:1
E@0:2
#E:2:2:2:2:2
P:4:TRADE_GENE:1:0
P:5:WINDFALL_GENE:0:0

N:Bio-Hazard Mining World
T:1:2:0
E@0:1
#E:1:1:1:1:1
G:RARE
P:4:TRADE_GENE:2:0
P:5:PRODUCE:0:0

N:Deserted Alien Library
T:1:6:5
E@0:1
#E:1:1:1:1:1
G:ALIEN
F:WINDFALL | ALIEN

N:Destroyed World
T:1:1:0
E@0:1
#E:1:1:1:1:1
G:RARE
F:WINDFALL

N:Galactic Renaissance
T:2:6:0
E@0:1
#E:1:1:1:1:1
P:1:DRAW:2:0
P:1:KEEP:1:0
V:1:THREE_VP:N/A
V:3:NAME:Research Labs
V:3:NAME:Galactic Trendsetters
V:3:NAME:Artist Colony

N:Blaster Gem Mines
T:1:3:2
E@0:1
#E:1:1:1:1:1
G:RARE
F:WINDFALL
P:3:EXTRA_MILITARY:1:0

N:Gambling World
T:1:1:1
E@0:1@2:-1
#E:1:1:0:0:1
P:4:CONSUME_ANY | GET_VP:1:1
P:4:DRAW_LUCKY:0:0

N:Expanding Colony
T:1:1:1
E@0:1
#E:1:1:1:1:1
P:4:CONSUME_ANY | GET_VP:1:1
P:5:WINDFALL_NOVELTY:0:0

N:Space Port
T:1:2:1
E@0:1
#E:1:1:1:1:1
G:NOVELTY
P:4:TRADE_RARE:2:0
P:5:PRODUCE:0:0

N:Prosperous World
T:1:3:2
E@0:1
#E:1:1:1:1:1
G:NOVELTY
P:4:CONSUME_ANY | GET_VP:1:1
P:5:PRODUCE:0:0

N:New Earth
T:1:5:3
E@0:1
#E:1:1:1:1:1
G:RARE
P:4:CONSUME_ANY | GET_CARD | GET_VP:1:1
P:5:PRODUCE:0:0

N:Rebel Base
T:1:6:6
E@0:1
#E:1:1:1:1:1
F:MILITARY | REBEL

N:Galactic Imperium
T:2:6:0
E@0:1
#E:1:1:1:1:1
F:IMPERIUM
P:3:BONUS_MILITARY | AGAINST_REBEL:4:0
V:2:REBEL_MILITARY:N/A
V:1:MILITARY:N/A

N:Trade League
T:2:6:0
E@0:1
#E:1:1:1:1:1
P:4:TRADE_ANY:1:0
P:4:TRADE_ACTION:0:0
V:2:DEVEL_TRADE:N/A
V:1:WORLD_TRADE:N/A

N:Mining World
T:1:3:2
E@0:1
#E:1:1:1:1:1
G:RARE
P:5:PRODUCE:0:0
P:5:DRAW_IF:1:0

#
# First expansion: The Gathering Storm
#

N:Separatist Colony
T:1:2:1
E@1:1
#E:0:1:1:1:0
F:START | START_RED
P:1:DRAW:2:0
P:3:EXTRA_MILITARY:1:0

N:Ancient Race
T:1:2:1
E@1:1
#E:0:1:1:1:0
G:GENE
F:START | START_BLUE | WINDFALL | STARTHAND_3

N:Damaged Alien Factory
T:1:3:2
E@1:1
#E:0:1:1:1:0
G:ALIEN
F:START | START_RED | MILITARY | ALIEN
P:5:DISCARD_HAND | PRODUCE:0:0

N:Doomed World
T:1:1:-1
E@1:1
#E:0:1:1:1:0
F:START | START_BLUE
P:1:DRAW:1:0
P:3:DISCARD | REDUCE_ZERO:0:0

N:Terraforming Guild
T:2:6:0
E@1:1
#E:0:1:1:1:0
F:TERRAFORMING
P:3:DRAW_AFTER:1:0
P:5:WINDFALL_ANY:0:0
V:2:NOVELTY_WINDFALL:N/A
V:2:RARE_WINDFALL:N/A
V:2:GENE_WINDFALL:N/A
V:2:ALIEN_WINDFALL:N/A
V:2:TERRAFORMING_FLAG:N/A

N:Galactic Genome Project
T:2:6:0
E@1:1
#E:0:1:1:1:0
P:4:CONSUME_GENE | CONSUME_TWO | GET_VP:3:1
V:2:GENE_PRODUCTION:N/A
V:2:GENE_WINDFALL:N/A
V:3:NAME:Genetics Lab

N:Space Mercenaries
T:2:1:0
E@1:2
#E:0:2:2:2:0
P:3:EXTRA_MILITARY:1:0
P:3:MILITARY_HAND:2:0

N:Improved Logistics
T:2:3:2
E@1:2
#E:0:2:2:2:0
P:3:PLACE_TWO:0:0

N:Deserted Alien World
T:1:1:2
E@1:1
#E:0:1:1:1:0
F:ALIEN
P:1:DRAW:1:0
P:3:REDUCE | ALIEN:2:0
P:3:BONUS_MILITARY | ALIEN:2:0

N:Rebel Colony
T:1:4:4
E@1:1
#E:0:1:1:1:0
F:MILITARY | REBEL
P:4:CONSUME_ANY | GET_VP:1:1

N:Clandestine Uplift Lab
T:1:3:2
E@1:1
#E:0:1:1:1:0
F:MILITARY | UPLIFT | CHROMO
P:1:DRAW:1:0
P:4:TRADE_GENE | TRADE_BONUS_CHROMO:0:0
P:4:CONSUME_ANY | GET_VP | GET_CARD:1:1

N:Imperium Lords
T:2:6:0
E@1:1
#E:0:1:1:1:0
F:IMPERIUM
P:5:DRAW_MILITARY:1:0
V:2:IMPERIUM_FLAG:N/A
V:1:MILITARY:N/A

N:Smuggling Lair
T:1:1:1
E@1:1
#E:0:1:1:1:0
G:RARE
F:MILITARY | WINDFALL
P:4:CONSUME_ANY | GET_2_CARD:1:1

N:Volcanic World
T:1:2:1
E@1:1
#E:0:1:1:1:0
G:RARE
P:5:PRODUCE:0:0

N:Rebel Sympathizers
T:1:1:1
E@1:1
#E:0:1:1:1:0
G:NOVELTY
F:MILITARY | REBEL | WINDFALL
P:5:DRAW_IF:1:0

N:Galactic Bazaar
T:1:3:2
E@1:1
#E:0:1:1:1:0
G:NOVELTY
F:WINDFALL
P:4:TRADE_NOVELTY:1:0
P:4:DISCARD_HAND | GET_VP:1:1

N:Galactic Studios
T:1:5:3
E@1:1
#E:0:1:1:1:0
G:NOVELTY
P:4:CONSUME_ANY | GET_VP | GET_CARD:1:1
P:5:PRODUCE:0:0
P:5:DRAW_IF:1:0

N:Alien Toy Shop
T:1:3:1
E@1:1
#E:0:1:1:1:0
G:ALIEN
F:WINDFALL | ALIEN
P:4:CONSUME_ALIEN | CONSUME_THIS | GET_VP:2:1

N:Hive World
T:1:3:2
E@1:1
#E:0:1:1:1:0
G:GENE
F:MILITARY
P:5:PRODUCE:0:0

#
# Second expansion: Rebel vs Imperium
#

N:Rebel Cantina
T:1:2:0
E@2:1
#E:0:0:1:1:0
F:START | START_RED | REBEL
P:3:PAY_MILITARY:0:0
P:5:DRAW_REBEL:1:0

N:Galactic Developers
T:1:2:1
E@2:1
#E:0:0:1:1:0
F:START | START_BLUE
P:2:DRAW:1:0
P:4:CONSUME_ANY | GET_VP:1:1

N:Imperium Warlord
T:1:2:2
E@2:1
#E:0:0:1:1:0
F:START | START_RED | IMPERIUM
P:1:DRAW:1:0
P:3:EXTRA_MILITARY:1:0
P:3:BONUS_MILITARY | AGAINST_REBEL:1:0

N:Rebel Stronghold
T:1:9:9
E@2:1
#E:0:0:1:1:0
F:REBEL | MILITARY | PRESTIGE

N:Alien Data Repository
T:1:7:6
E@2:1
#E:0:0:1:1:0
G:ALIEN
F:ALIEN
P:1:DISCARD_ANY:0:0
P:5:PRODUCE:0:0

N:Alien Monolith
T:1:8:8
E@2:1
#E:0:0:1:1:0
G:ALIEN
F:ALIEN | WINDFALL | MILITARY | PRESTIGE

N:Imperium Blaster Gem Consortium
T:1:6:4
E@2:1
#E:0:0:1:1:0
G:RARE
F:IMPERIUM | PRESTIGE
P:3:EXTRA_MILITARY:1:0
P:4:CONSUME_RARE | GET_VP | GET_2_CARD:1:1
P:5:PRODUCE:0:0

N:Gene Designers
T:1:6:3
E@2:1
#E:0:0:1:1:0
G:GENE
P:4:CONSUME_GENE | GET_VP | GET_CARD:1:3
P:5:PRODUCE:0:0

N:Imperium Seat
T:2:6:0
E@2:1
#E:0:0:1:1:0
F:IMPERIUM
P:3:BONUS_MILITARY | AGAINST_REBEL:1:0
P:3:TAKEOVER_REBEL:0:0
V:2:IMPERIUM_FLAG:N/A
V:2:REBEL_MILITARY:N/A

N:Rebel Alliance
T:2:6:0
E@2:1
#E:0:0:1:1:0
F:REBEL
P:3:PAY_MILITARY | AGAINST_REBEL:2:0
P:3:TAKEOVER_IMPERIUM:2:0
V:2:REBEL_FLAG:N/A
V:1:MILITARY:N/A

N:Uplift Code
T:2:6:0
E@2:1
#E:0:0:1:1:0
F:UPLIFT | PRESTIGE
P:5:DRAW_CHROMO:2:0
V:3:CHROMO_FLAG:N/A
V:2:UPLIFT_FLAG:N/A

N:Galactic Exchange
T:2:6:0
E@2:1
#E:0:0:1:1:0
P:4:CONSUME_N_DIFF | GET_VP | GET_CARD:1:1
V:0:KIND_GOOD:N/A
V:3:NAME:Diversified Economy

N:Galactic Bankers
T:2:6:0
E@2:1
#E:0:0:1:1:0
F:PRESTIGE
P:2:DRAW:1:0
P:4:DISCARD_HAND | GET_VP:1:2
V:2:NAME:Interstellar Bank
V:2:NAME:Investment Credits
V:2:NAME:Gambling World
V:1:DEVEL:N/A

N:Prospecting Guild
T:2:6:0
E@2:1
#E:0:0:1:1:0
P:1:DISCARD_ANY:0:0
P:4:TRADE_ANY:1:0
P:4:CONSUME_RARE | GET_VP | GET_CARD:1:1
V:2:RARE_PRODUCTION:N/A
V:2:RARE_WINDFALL:N/A
V:1:WORLD:N/A
V:1:TERRAFORMING_FLAG:N/A

N:Pan-Galactic Research
T:2:6:4
E@2:1
#E:0:0:1:1:0
F:DISCARD_TO_12
P:1:DRAW:2:0
P:1:KEEP:1:0
P:2:REDUCE:1:0
P:5:DRAW:2:0

N:Rebel Pact
T:2:1:1
E@2:2
#E:0:0:2:2:0
F:REBEL
P:1:DISCARD_ANY:0:0
P:3:PAY_DISCOUNT:2:0
P:3:TAKEOVER_DEFENSE:0:0

N:Imperium Cloaking Technology
T:2:1:1
E@2:2
#E:0:0:2:2:0
F:IMPERIUM
P:3:DISCARD_CONQUER_SETTLE | NO_TAKEOVER:2:0
P:3:DISCARD | TAKEOVER_MILITARY:0:0

N:Imperium Troops
T:2:1:1
E@2:2
#E:0:0:2:2:0
F:IMPERIUM
P:3:EXTRA_MILITARY:1:0
P:3:BONUS_MILITARY | AGAINST_REBEL:1:0

N:R&D Crash Program
T:2:1:0
E@2:2
#E:0:0:2:2:0
P:2:DISCARD_REDUCE:3:0
P:4:DISCARD_HAND | GET_CARD:1:1

N:Mercenary Fleet
T:2:3:1
E@2:2
#E:0:0:2:2:0
P:3:EXTRA_MILITARY:2:0
P:3:MILITARY_HAND:2:0

N:Galactic Advertisers
T:2:3:2
E@2:2
#E:0:0:2:2:0
P:4:TRADE_ANY:1:0
P:4:DRAW:1:0

N:Galactic Salon
T:2:4:2
E@2:2
#E:0:0:2:2:0
P:4:VP:1:0

N:Primitive Rebel World
T:1:1:1
E@2:1
#E:0:0:1:1:0
G:NOVELTY
F:REBEL | MILITARY | WINDFALL
P:3:MILITARY_HAND:1:0

N:Devolved Uplift Race
T:1:1:1
E@2:1
#E:0:0:1:1:0
G:NOVELTY
F:UPLIFT | MILITARY | CHROMO
P:5:PRODUCE:0:0

N:Smuggling World
T:1:1:0
E@2:1
#E:0:0:1:1:0
G:NOVELTY
P:1:DISCARD_ANY:0:0
P:3:REDUCE | NOVELTY:1:0
P:3:BONUS_MILITARY | NOVELTY:1:0
P:5:PRODUCE:0:0

N:Dying Colony
T:1:0:0
E@2:1
#E:0:0:1:1:0
G:NOVELTY
F:WINDFALL
P:4:CONSUME_ANY | GET_VP:1:1

N:Insect Uplift Race
T:1:2:2
E@2:1
#E:0:0:1:1:0
G:GENE
F:WINDFALL | UPLIFT | MILITARY | CHROMO

N:Abandoned Alien Uplift Camp
T:1:1:2
E@2:1
#E:0:0:1:1:0
F:ALIEN | UPLIFT
P:1:DRAW:1:0
P:3:REDUCE | GENE:2:0
P:3:BONUS_MILITARY | GENE:2:0

N:Blaster Runners
T:1:1:1
E@2:1
#E:0:0:1:1:0
F:MILITARY
P:1:DISCARD_ANY:0:0
P:3:EXTRA_MILITARY:1:0

N:Trading Outpost
T:1:1:1
E@2:1
#E:0:0:1:1:0
P:1:DISCARD_ANY:0:0
P:4:TRADE_ANY:2:0

N:Gambling World
T:1:1:1
E@2:1
#E:0:0:1:1:0
P:4:CONSUME_ANY | GET_VP:1:1
P:4:ANTE_CARD:0:0

N:Alien Uplift Center
T:1:5:4
E@2:1
#E:0:0:1:1:0
G:ALIEN
F:ALIEN | UPLIFT | MILITARY | WINDFALL
P:1:DRAW:1:0
P:3:REDUCE | GENE:2:0
P:3:BONUS_MILITARY | GENE:2:0

N:Universal Symbionts
T:1:3:1
E@2:1
#E:0:0:1:1:0
G:GENE
F:WINDFALL
P:4:CONSUME_ANY | GET_VP:1:1
P:5:WINDFALL_GENE | NOT_THIS:0:0

N:Interstellar Prospectors
T:1:3:2
E@2:1
#E:0:0:1:1:0
G:RARE
P:1:DRAW:1:0
P:5:PRODUCE:0:0
P:5:WINDFALL_RARE:0:0

N:Rebel Convict Mines
T:1:2:1
E@2:1
#E:0:0:1:1:0
G:RARE
F:MILITARY | WINDFALL | REBEL
P:3:MILITARY_HAND:1:0

N:Gem Smugglers
T:1:3:1
E@2:1
#E:0:0:1:1:0
G:RARE
F:WINDFALL
P:1:DISCARD_ANY:0:0
P:3:REDUCE | RARE:1:0
P:3:BONUS_MILITARY | RARE:1:0

N:Hidden Fortress
T:1:5:3
E@2:1
#E:0:0:1:1:0
F:MILITARY | GAME_END_14
P:3:EXTRA_MILITARY | PER_MILITARY:1:0

#
# Third expansion: The Brink of War
#

N:Galactic Scavengers
T:1:2:0
E@3:1
#E:0:0:0:1:0
G:NOVELTY
F:WINDFALL | START | START_BLUE | START_SAVE
P:2:SAVE_COST:1:0
P:3:SAVE_COST:1:0
P:5:TAKE_SAVED:0:0

N:Uplift Mercenary Force
T:1:2:0
E@3:1
#E:0:0:0:1:0
F:START | START_RED | UPLIFT | CHROMO
P:1:DRAW:1:0
P:3:EXTRA_MILITARY | PER_CHROMO:1:0
P:3:MILITARY_HAND:1:0

N:Alien Research Team
T:1:2:1
E@3:1
#E:0:0:0:1:0
F:START | START_BLUE | ALIEN
P:1:DRAW:2:0
P:3:REDUCE | ALIEN:1:0
P:3:PAY_MILITARY | ALIEN:0:0
P:4:CONSUME_ALIEN | GET_PRESTIGE:1:1

N:Rebel Freedom Fighters
T:1:3:1
E@3:1
#E:0:0:0:1:0
F:START | START_RED | MILITARY | REBEL
P:1:DRAW:1:0
P:2:PRESTIGE_REBEL:1:0
P:3:EXTRA_MILITARY:1:0
P:3:IMPERIUM_MILITARY:-2:0
P:3:PRESTIGE_REBEL:1:0

N:Imperium Capital
T:1:6:6
E@3:1
#E:0:0:0:1:0
F:IMPERIUM | PRESTIGE
P:3:PRESTIGE_REBEL:1:0
P:4:CONSUME_ANY | CONSUME_TWO | GET_PRESTIGE:2:1

N:Alien Oort Cloud Refinery
T:1:0:1
E@3:1
#E:0:0:0:1:0
G:ANY
F:ALIEN | WINDFALL
P:4:NO_TRADE:0:0

N:Golden Age of Terraforming
T:2:6:0
E@3:1
#E:0:0:0:1:0
F:TERRAFORMING | PRESTIGE
P:2:CONSUME_RARE:2:0
P:3:CONSUME_GENE | REDUCE:3:0
P:3:AUTO_PRODUCE:0:0
V:2:TERRAFORMING_FLAG:N/A
V:1:SIX_DEVEL:N/A
V:1:NOVELTY_PRODUCTION:N/A
V:1:RARE_PRODUCTION:N/A
V:1:GENE_PRODUCTION:N/A
V:1:ALIEN_PRODUCTION:N/A

N:Universal Peace Institute
T:2:6:0
E@3:1
#E:0:0:0:1:0
F:PRESTIGE
P:3:REDUCE:2:0
P:3:EXTRA_MILITARY:-2:0
P:4:CONSUME_ANY | CONSUME_TWO | GET_PRESTIGE | GET_VP | GET_CARD:1:1
V:1:NEGATIVE_MILITARY:N/A
V:1:MILITARY:N/A
V:2:NAME:Pan-Galactic Mediator

N:Interstellar Casus Belli
T:2:4:0
E@3:2
#E:0:0:0:2:0
P:3:TAKEOVER_PRESTIGE:2:0
P:4:CONSUME_PRESTIGE | GET_VP:3:1

N:Imperium Fuel Depot
T:1:3:1
E@3:1
#E:0:0:0:1:0
G:RARE
F:MILITARY | IMPERIUM
P:3:EXPLORE_AFTER:2:0
P:5:PRODUCE:0:0

N:Imperium Invasion Fleet
T:2:5:3
E@3:2
#E:0:0:0:2:0
F:IMPERIUM | PRESTIGE
P:3:EXTRA_MILITARY:3:0
P:3:BONUS_MILITARY | AGAINST_REBEL:1:0
P:3:DISCARD_CONQUER_SETTLE | PRESTIGE:0:0

N:Uplift Gene Breeders
T:1:3:0
E@3:1
#E:0:0:0:1:0
G:GENE
F:UPLIFT
P:5:PRODUCE:0:0
P:5:PRESTIGE_IF:1:0

N:Pan-Galactic Security Council
T:1:1:1
E@3:1
#E:0:0:0:1:0
F:PRESTIGE
P:1:DRAW:1:0
P:3:PREVENT_TAKEOVER:0:0
P:4:DISCARD_HAND | CONSUME_TWO | GET_PRESTIGE:1:1

N:Imperium Planet Buster
T:2:9:9
E@3:1
#E:0:0:0:1:0
F:IMPERIUM | PRESTIGE
P:3:EXTRA_MILITARY:3:0
P:3:TAKEOVER_MILITARY | DESTROY:2:0

N:Federation Capital
T:1:3:0
E@3:1
#E:0:0:0:1:0
P:2:PRESTIGE_SIX:1:0
P:4:CONSUME_ANY | GET_PRESTIGE:1:1
V:1:PRESTIGE:N/A

N:Mining Mole Uplift Race
T:1:3:2
E@3:1
#E:0:0:0:1:0
G:RARE
F:UPLIFT | CHROMO
P:1:DRAW:1:0
P:3:REDUCE | RARE:1:0
P:5:PRODUCE:0:0

N:Pan-Galactic Mediator
T:2:1:1
E@3:2
#E:0:0:0:2:0
F:PRESTIGE
P:1:DRAW:1:0
P:3:EXTRA_MILITARY:-1:0
P:3:PAY_PRESTIGE:1:0

N:Alien Departure Point
T:1:9:9
E@3:1
#E:0:0:0:1:0
G:ALIEN
F:ALIEN | PRESTIGE
P:1:DISCARD_PRESTIGE:1:0
P:5:PRODUCE:0:0

N:Rebel Troops
T:2:2:1
E@3:2
#E:0:0:0:2:0
F:REBEL
P:3:EXTRA_MILITARY:1:0
P:3:MILITARY_HAND:1:0
P:4:CONSUME_ANY | GET_2_CARD:1:1

N:Retrofit & Salvage, Inc
T:1:2:1
E@3:1
#E:0:0:0:1:0
G:NOVELTY
F:TAKE_DISCARDS
P:2:REDUCE:1:0
P:5:PRODUCE:0:0

N:Uplift Revolt World
T:1:4:2
E@3:1
#E:0:0:0:1:0
G:GENE
F:MILITARY | WINDFALL | UPLIFT | CHROMO
P:3:EXTRA_MILITARY | PER_CHROMO:1:0

N:Terraforming Engineers
T:2:3:2
E@3:2
#E:0:0:0:2:0
F:TERRAFORMING
P:1:DRAW:1:0
P:3:REDUCE:1:0
P:3:UPGRADE_WORLD:3:0
P:4:CONSUME_ANY | GET_VP:1:1

N:Alien Tourist Attraction
T:1:5:3
E@3:1
#E:0:0:0:1:0
G:NOVELTY
F:ALIEN | WINDFALL | PRESTIGE
P:1:DRAW:1:0
P:4:CONSUME_ANY | GET_VP | GET_2_CARD:1:1

N:Lifeforms, Inc
T:1:3:1
E@3:1
#E:0:0:0:1:0
G:GENE
P:3:CONSUME_GENE | REDUCE:3:0
P:5:PRODUCE:0:0
P:5:DISCARD_HAND | WINDFALL_GENE:1:0

N:Rebel Council
T:1:8:8
E@3:1
#E:0:0:0:1:0
F:REBEL | MILITARY | PRESTIGE
P:2:PRESTIGE_REBEL:1:0
P:4:CONSUME_ANY | GET_VP:1:1

N:Galactic Markets
T:2:4:2
E@3:2
#E:0:0:0:2:0
F:PRESTIGE
P:3:DRAW_AFTER:1:0
P:4:CONSUME_ANY | GET_VP:1:3
P:5:DRAW:1:0

N:Alien Booby Trap
T:1:1:1
E@3:1
#E:0:0:0:1:0
F:MILITARY | ALIEN | PRESTIGE
P:3:CONSUME_PRESTIGE | EXTRA_MILITARY:3:1
P:5:DISCARD_HAND | WINDFALL_ALIEN:1:0

N:Rebel Sneak Attack
T:2:2:1
E@3:2
#E:0:0:0:2:0
F:REBEL
P:1:DISCARD_ANY:0:0
P:3:DISCARD | PLACE_MILITARY:0:0
P:3:DISCARD | TAKEOVER_IMPERIUM:2:0

N:Pan-Galactic Hologrid
T:2:6:0
E@3:1
#E:0:0:0:1:0
P:1:DISCARD_PRESTIGE:1:0
P:3:DRAW_AFTER:1:0
P:4:TRADE_NOVELTY:2:0
V:2:NOVELTY_PRODUCTION:N/A
V:2:NOVELTY_WINDFALL:N/A
V:2:NAME:Expanding Colony
V:1:WORLD:N/A

N:Alien Burial Site
T:1:2:1
E@3:1
#E:0:0:0:1:0
G:NOVELTY
F:ALIEN | PRESTIGE
P:4:TRADE_NOVELTY:1:0
P:5:PRODUCE:0:0

N:Pan-Galactic Affluence
T:2:6:0
E@3:1
#E:0:0:0:1:0
F:PRESTIGE
P:2:PRESTIGE:1:0
P:4:CONSUME_ANY | CONSUME_TWO | GET_PRESTIGE | GET_VP:1:1
P:5:DRAW_MOST_PRODUCED:1:0
V:1:PRESTIGE:N/A
V:2:NAME:Export Duties
V:2:NAME:Galactic Renaissance
V:2:NAME:Terraformed World

N:Rebel Fuel Refinery
T:1:4:2
E@3:1
#E:0:0:0:1:0
G:RARE
F:REBEL | MILITARY | WINDFALL | PRESTIGE
P:3:CONSUME_RARE | EXTRA_MILITARY:2:0

N:Psi-Crystal World
T:1:5:3
E@3:1
#E:0:0:0:1:0
G:RARE
F:WINDFALL | PRESTIGE | SELECT_LAST
P:1:DRAW:1:0
P:3:EXTRA_MILITARY:-1:0

N:Ravaged Uplift World
T:1:2:-1
E@3:1
#E:0:0:0:1:0
G:GENE
F:WINDFALL | UPLIFT | CHROMO
P:3:PAY_MILITARY | AGAINST_CHROMO:0:0
P:5:PRESTIGE_MOST_CHROMO:1:0

N:Galactic Power Brokers
T:2:5:3
E@3:2
#E:0:0:0:2:0
F:PRESTIGE
P:2:EXPLORE:2:0
P:4:CONSUME_PRESTIGE | GET_3_CARD:1:1

N:Alien Cornucopia
T:2:6:0
E@3:1
#E:0:0:0:1:0
F:ALIEN
P:3:PRODUCE_PRESTIGE:1:0
P:5:DRAW:1:0
V:2:ALIEN_FLAG:N/A
V:1:NOVELTY_PRODUCTION:N/A
V:1:RARE_PRODUCTION:N/A
V:1:GENE_PRODUCTION:N/A

N:Information Hub
T:1:3:2
E@3:1
#E:0:0:0:1:0
G:NOVELTY
F:MILITARY | PRESTIGE
P:1:DISCARD_ANY:0:0
P:2:EXPLORE:1:0
P:5:PRODUCE:0:0

N:Alien Guardian
T:1:9:9
E@3:1
#E:0:0:0:1:0
G:ALIEN
F:ALIEN | MILITARY | WINDFALL | PRESTIGE
P:4:DISCARD_HAND | CONSUME_TWO | GET_PRESTIGE:1:1

N:Universal Exports
T:1:3:2
E@3:1
#E:0:0:0:1:0
G:NOVELTY
P:1:DISCARD_ANY:0:0
P:4:TRADE_ANY:1:0
P:5:PRODUCE:0:0
P:5:DISCARD_HAND | WINDFALL_ANY:1:0

N:Black Hole Miners
T:1:4:0
E@3:1
#E:0:0:0:1:0
F:PRESTIGE | DISCARD_TO_12
P:5:DRAW:3:0
]]

startWorlds = {
     ["Gateway Station"] = -6,
     ["Abandoned Mine Squatters"] = -5,
     ["Transforming Colonists"] = -4,
     ["Galactic Trade Emissaries"] = -3,
     ["Industrial Robots"] = -2,
     ["Star Nomad Raiders"] = -1,
     ["Old Earth"] = 0,
     ["Epsilon Eridani"] = 1,
     ["Alpha Centauri"] = 2,
     ["New Sparta"] = 3,
     ["Earth's Lost Colony"] = 4,
     ["Separatist Colony"] = 5,
     ["Ancient Race"] = 6,
     ["Damaged Alien Factory"] = 7,
     ["Doomed World"] = 8,
     ["Rebel Cantina"] = 9,
     ["Galactic Developers"] = 10,
     ["Imperium Warlord"] = 11,
     ["Galactic Scavengers"] = 12,
     ["Uplift Mercenary Force"] = 13,
     ["Alien Research Team"] = 14,
 }

-- key: name, value: tooltip
activePowers = {
     ["1"] = {
     },
     ["2"] = {
          DISCARD_REDUCE = "Discard this card to reduce cost.",
          CONSUME_RARE = "Consume Rare good."
     },
     ["3"] = {
          DISCARD = "Discard from tableau to ",
          DISCARD_CONQUER_SETTLE = "Discard from tableau to place normal world as military world.",
          PAY_MILITARY = "Place military world as normal world.",
          MILITARY_HAND = "Discard from hand for bonus military.",
          TAKEOVER_IMPERIUM = "Takeover military world from IMPERIUM tableau.",
          TAKEOVER_REBEL = "Takeover REBEL military world.",
          CONSUME_PRESTIGE = "Discard prestige to ",
          TAKEOVER_PRESTIGE = "Spend prestige to takeover military world.",
          TAKEOVER_MILITARY = "Takeover military world.",
          CONSUME_RARE = "Consume Rare good.",
          CONSUME_GENE = "Consume Genes good.",
          UPGRADE_WORLD = "Replace a world on tableau."
     },
     ["4"] = {
          TRADE_ACTION = "Sell a good.",
          CONSUME_ANY = "Consume any good.",
          CONSUME_NOVELTY = "Consume Novelty good.",
          CONSUME_RARE = "Consume Rare good.",
          CONSUME_GENE = "Consume Genes good.",
          CONSUME_ALIEN = "Consume Alien good.",
          CONSUME_3_DIFF = "Consume 3 different goods.",
          CONSUME_N_DIFF = "Consume different goods.",
          CONSUME_ALL = "Consume all goods.",
          CONSUME_PRESTIGE = "Consume prestige.",
          DISCARD_HAND = "Discard from hand.",
          DRAW = "Draw card(s).",
          ANTE_CARD = "Gamble draw.",
          DRAW_LUCKY = "Gamble draw.",
          VP = "Gain VP."
     },
     ["5"] = {
          DRAW = "Draw card(s)",
          DRAW_MILITARY = "Draw card(s)",
          WINDFALL_ANY = "Produce good on any windfall world.",
          WINDFALL_NOVELTY = "Produce good on Novelty windfall world.",
          WINDFALL_RARE = "Produce good on Rare windfall world.",
          WINDFALL_GENE = "Produce good on Genes windfall world.",
          WINDFALL_ALIEN = "Produce good on Alien windfall world.",
          DRAW_WORLD_GENE = "Draw 1 card for each Genes world in tableau.",
          DRAW_EACH_NOVELTY = "Draw 1 card for each Novelty good you produced.",
          DRAW_EACH_ALIEN = "Draw 1 card for each Alien good you produced.",
          DRAW_DIFFERENT = "Draw 1 card for each kind of good you produced.",
          DISCARD_HAND = "Discard from hand to use.",
          DRAW_CHROMO = "Draw 2 cards for each Gene world w/ Chromosome in tableau.",
          DRAW_REBEL = "Draw 1 card for each Rebel world in tableau.",
          TAKE_SAVED = "Draw all cards under this world."
     }
}

subtooltip = {
     REDUCE_ZERO = "settle normal world (non-Alien) for free.",
     EXTRA_MILITARY = "gain extra military.",
     TAKEOVER_MILITARY = "takeover military world."
}

takeoverPowers = {
     ["TAKEOVER_MILITARY"] = 1,
     ["TAKEOVER_REBEL"] = 1,
     ["TAKEOVER_IMPERIUM"] = 1,
     ["TAKEOVER_PRESTIGE"] = 1
}

function loadData(expansions)
     local tbl = {}
     local cardInfo = {}

     for line in magiclines(cardtxt) do

          -- skip comments
          if line:sub(1, 1) == "#" or line:len() <= 0 then
               goto endloop
          end

          do
               local code = line:sub(1,1)

               -- new card
               if code == "N" then
                    cardInfo = {}
                    cardInfo.name = line:sub(3, line:len())
                    cardInfo.passiveCount = {["1"]=0,["2"]=0,["3"]=0,["4"]=0,["5"]=0}
                    cardInfo.passivePowers = {}
                    cardInfo.activeCount = {["1"]=0,["2"]=0,["3"]=0,["4"]=0,["5"]=0}
                    cardInfo.activePowers = {}
                    cardInfo.flags = {}
                    tbl[cardInfo.name] = cardInfo
               -- card type (world or development), cost, and vp
               elseif code == "T" then
                    local tokens = split(line, ":")
                    cardInfo.type = tonumber(tokens[2])
                    cardInfo.cost = tonumber(tokens[3])
                    cardInfo.vp = tonumber(tokens[4])
               -- expansion (need only the first value)
               elseif code == "E" then
                    cardInfo.expansion = line:sub(3,3)
               -- flags
               elseif code == "F" then
                    local tokens = split(all_trim(line:sub(3, line:len())),"|")
                    local flags = {}
                    for i=1, #tokens do
                         flags[tokens[i]] = true
                    end
                    cardInfo.flags = flags
               -- goodtype
               elseif code == "G" then
                    cardInfo.goods = line:sub(3, line:len())
               -- powers
               elseif code == "P" then
                    local tokens = split(line,":")
                    local power = {}
                    local phase = tokens[2]

                    if not cardInfo.activePowers[phase] then
                         cardInfo.activePowers[phase] = {}
                    end
                    if not cardInfo.passivePowers[phase] then
                         cardInfo.passivePowers[phase] = {}
                    end

                    power.codes = split(all_trim(tokens[3]),"|")
                    power.name = power.codes[1]
                    power.strength = tonumber(tokens[4])
                    power.times = tonumber(tokens[5])

                    local newCodes = {}
                    for i=2, #power.codes do
                         newCodes[power.codes[i]] = true
                    end

                    power.codes = newCodes

                    if activePowers[phase][power.name] then
                         cardInfo.activePowers[tokens[2]][power.name] = power
                         cardInfo.activeCount[phase] = cardInfo.activeCount[phase] + 1
                         power.index = cardInfo.activeCount[phase]
                    else
                         cardInfo.passivePowers[tokens[2]][power.name] = power
                         cardInfo.passiveCount[phase] = cardInfo.passiveCount[phase] + 1
                         power.index = cardInfo.passiveCount[phase]
                    end
               -- vp flags
               elseif code == "V" then
                    local tokens = split(line,":")
                    local vpFlags = {}
                    local type = tokens[3]
                    local value = tonumber(tokens[2])
                    local matchName = tokens[4]

                    if cardInfo.vpFlags == nil then
                         cardInfo.vpFlags = {}
                    end

                    if type == "NAME" then
                         if not cardInfo.vpFlags[type] then
                              cardInfo.vpFlags[type] = {}
                         end

                         cardInfo.vpFlags[type][#cardInfo.vpFlags[type] + 1] = {name = matchName, vp = value}
                    else
                         cardInfo.vpFlags[type] = value
                    end
               end
          end

          ::endloop::
     end

     return tbl
end