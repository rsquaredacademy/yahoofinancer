pkgname <- "FinNet"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
options(pager = "console")
library('FinNet')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("FF")
### * FF

flush(stderr()); flush(stdout())

### Name: FF
### Title: Create any firm-firm (FF) matrix
### Aliases: FF

### ** Examples


# Create the normalised FF matrix of Berkshire Hathaway's holdings by boards interlocks
data('firms_BKB')
FF <- FF(firms_BKB, who = 'man', ties = 'share')




cleanEx()
nameEx("FF.binary.both")
### * FF.binary.both

flush(stderr()); flush(stdout())

### Name: FF.binary.both
### Title: Create a complete binary firm-firm (FF) matrix
### Aliases: FF.binary.both

### ** Examples


# Create the complete binary firm-firm matrix for the companies held by Berkshire Hathaway
data('firms_BKB')
FF <- FF.binary.both(firms_BKB)





cleanEx()
nameEx("FF.binary.management")
### * FF.binary.management

flush(stderr()); flush(stdout())

### Name: FF.binary.management
### Title: Create a binary firm-firm (FF) matrix for board interlocks
### Aliases: FF.binary.management

### ** Examples


# Create the binary FF matrix of Berkshire Hathaway's holdings by boards interlock
data('firms_BKB')
FF <- FF.binary.management(firms_BKB)





cleanEx()
nameEx("FF.binary.ownership")
### * FF.binary.ownership

flush(stderr()); flush(stdout())

### Name: FF.binary.ownership
### Title: Create a binary firm-firm (FF) matrix for common ownership
### Aliases: FF.binary.ownership

### ** Examples


# Create the binary FF matrix of Berkshire Hathaway's holdings by common ownership
data('firms_BKB')
FF <- FF.binary.ownership(firms_BKB)





cleanEx()
nameEx("FF.graph")
### * FF.graph

flush(stderr()); flush(stdout())

### Name: FF.graph
### Title: Easily represent a firm-firm (FF) network using the package
###   'igraph'
### Aliases: FF.graph

### ** Examples

# Create a nice graph representation of the binary FF of
# Berkshire Hataway's holdings based on common ownership
data("firms_BKB")
x <- FF.naive.ownership(firms_BKB)
FF.graph(x = x, aesthetic = 'nice')




cleanEx()
nameEx("FF.graph.custom")
### * FF.graph.custom

flush(stderr()); flush(stdout())

### Name: FF.graph.custom
### Title: Represent a firm-firm (FF) network using the package 'igraph'
### Aliases: FF.graph.custom

### ** Examples

# Create the graph representation of the binary FF of
# Berkshire Hataway's holdings based on common ownership
data("firms_BKB")
x <- FF.naive.ownership(firms_BKB)
FF.graph.custom(x = x, node.size = 3)




cleanEx()
nameEx("FF.naive.both")
### * FF.naive.both

flush(stderr()); flush(stdout())

### Name: FF.naive.both
### Title: Create a complete naive-valued firm-firm (FF) matrix
### Aliases: FF.naive.both

### ** Examples


# Create the complete naive firm-firm matrix for the companies held by Berkshire Hathaway
data('firms_BKB')
FF <- FF.naive.both(firms_BKB)




cleanEx()
nameEx("FF.naive.management")
### * FF.naive.management

flush(stderr()); flush(stdout())

### Name: FF.naive.management
### Title: Create a naive-valued firm-firm (FF) matrix for boards
###   interlocks
### Aliases: FF.naive.management

### ** Examples


# Create the naive FF matrix of Berkshire Hathaway's holdings by boards interlocks
data('firms_BKB')
FF <- FF.naive.management(firms_BKB)




cleanEx()
nameEx("FF.naive.ownership")
### * FF.naive.ownership

flush(stderr()); flush(stdout())

### Name: FF.naive.ownership
### Title: Create a naive-valued firm-firm (FF) matrix for common ownership
### Aliases: FF.naive.ownership

### ** Examples


# Create the naive FF matrix of Berkshire Hathaway's holdings by common ownership
data('firms_BKB')
FF <- FF.naive.ownership(firms_BKB)




cleanEx()
nameEx("FF.net")
### * FF.net

flush(stderr()); flush(stdout())

### Name: FF.net
### Title: Easily represent a firm-firm (FF) network using the package
###   'network'
### Aliases: FF.net

### ** Examples

# Create a nice network representation of the binary FF of
# Berkshire Hataway's holdings based on common ownership
data("firms_BKB")
x <- FF.naive.ownership(firms_BKB)
FF.net(x = x, aesthetic = 'nice')




cleanEx()
nameEx("FF.net.custom")
### * FF.net.custom

flush(stderr()); flush(stdout())

### Name: FF.net.custom
### Title: Represent a firm-firm (FF) network using the package 'network'
### Aliases: FF.net.custom

### ** Examples

# Create the network representation of the binary FF of
# Berkshire Hataway's holdings based on common ownership
data("firms_BKB")
x <- FF.naive.ownership(firms_BKB)
FF.net.custom(x = x, node.size = 3)




cleanEx()
nameEx("FF.norm.both")
### * FF.norm.both

flush(stderr()); flush(stdout())

### Name: FF.norm.both
### Title: Create a complete normalised-valued firm-firm (FF) matrix
### Aliases: FF.norm.both

### ** Examples


# Create the complete normalised firm-firm matrix for the companies held by Berkshire Hathaway
data('firms_BKB')
FF <- FF.norm.both(firms_BKB)





cleanEx()
nameEx("FF.norm.management")
### * FF.norm.management

flush(stderr()); flush(stdout())

### Name: FF.norm.management
### Title: Create a normalised-valued firm-firm (FF) matrix for boards
###   interlocks
### Aliases: FF.norm.management

### ** Examples


# Create the normalised FF matrix of Berkshire Hathaway's holdings by boards interlocks
data('firms_BKB')
FF <- FF.norm.management(firms_BKB)




cleanEx()
nameEx("FF.norm.ownership")
### * FF.norm.ownership

flush(stderr()); flush(stdout())

### Name: FF.norm.ownership
### Title: Create a normalised-valued firm-firm (FF) matrix for common
###   ownership
### Aliases: FF.norm.ownership

### ** Examples


# Create the normalised FF matrix of Berkshire Hathaway's holdings by common ownership
data('firms_BKB')
FF <- FF.norm.ownership(firms_BKB)




cleanEx()
nameEx("FM")
### * FM

flush(stderr()); flush(stdout())

### Name: FM
### Title: Function to create a (necessarily binary) firm-manager (FM)
###   matrix
### Aliases: FM

### ** Examples


# Create the FM matrix of Berkshire Hathaway's holdings




cleanEx()
nameEx("FO.binary")
### * FO.binary

flush(stderr()); flush(stdout())

### Name: FO.binary
### Title: Function to create a binary firm-owner (FO) matrix
### Aliases: FO.binary

### ** Examples


# Create the binary FO matrix of Berkshire Hathaway's holdings




cleanEx()
nameEx("FO.naive")
### * FO.naive

flush(stderr()); flush(stdout())

### Name: FO.naive
### Title: Function to create a naive-valued firm-owner (FO) matrix
### Aliases: FO.naive

### ** Examples


# Create the naive FO matrix of Berkshire Hathaway's holdings




cleanEx()
nameEx("FO.norm")
### * FO.norm

flush(stderr()); flush(stdout())

### Name: FO.norm
### Title: Function to create a naive-valued firm-owner (FO) matrix
### Aliases: FO.norm

### ** Examples


# Create the normalised FO matrix of Berkshire Hathaway's holdings




cleanEx()
nameEx("cfa")
### * cfa

flush(stderr()); flush(stdout())

### Name: cfa
### Title: Perform cascade failure analysis
### Aliases: cfa

### ** Examples

# Create a matrix
mat <- matrix(c(
    0, 1, 0, 1, 0, 1, 0, 0,
    0, 0, 1, 0, 0, 0, 0, 0,
    1, 0, 0, 0, 0, 0, 0, 0,
    0, 1, 1, 0, 1, 0, 0, 0,
    0, 0, 0, 1, 0, 1, 0, 0,
    0, 0, 1, 0, 0, 0, 1, 0,
   0, 0, 0, 0, 0, 1, 0, 0,
    0, 0, 0, 0, 1, 0, 1, 1
  ),ncol = 8, byrow = TRUE)
# Add rownames
rownames(mat) <- paste0("Firm", LETTERS[1:ncol(mat)])

# Create a FF matrix
mat <- methods::new('financial_matrix',
                    M = mat,
                    relation = c('own'),
                    legal_form = c('JSC'),
                    sector = c('A.01'),
                    revenues = c(NA),
                    capitalisation = c(NA),
                    currency = c('USD'))

# Notice the differnce between:
# a. CFA with ordering by in-degree (decreasing)
# b. CFA with ordering by in-degree (increasing)
cfa(mat, ordering = 'in', decreasing = FALSE)
# But ordering by increasing (decreasing) in-degree is the
# same as ordering by decreasing (increasing) out-degree and
# vice versa!
cfa(mat, ordering = 'out', decreasing = FALSE) # By out-degree (increasing)




cleanEx()
nameEx("fiedler")
### * fiedler

flush(stderr()); flush(stdout())

### Name: fiedler
### Title: Calculate the Fiedler value (algebraic connectivity)
### Aliases: fiedler

### ** Examples

# Load some data
data('firms_BKB')
# Create a FF matrix
mat <- FF(firms_BKB, who = 'b', ties =  'n')
fiedler(mat)

# Create a FF network
if(!require('network')){
  net <- FF.net(mat, 'simple')
  fiedler(net)==fiedler(mat)
}

# Create a FF graph
if(!require('igraph')){
  g <- FF.graph(mat, 'simple')
  fiedler(g)==fiedler(mat)
}




cleanEx()
nameEx("find.firm")
### * find.firm

flush(stderr()); flush(stdout())

### Name: find.firm
### Title: Function to create a 'firm' (legal person) using data from
###   'Yahoo! Finance'
### Aliases: find.firm

### ** Examples

# Registering Apple automatically
#| Results are subject to the correct functioning of the package `yahoofinancer`
#| and of the Yahoo! Finance API




cleanEx()
nameEx("find.firms")
### * find.firms

flush(stderr()); flush(stdout())

### Name: find.firms
### Title: Function to create mutiple 'firms' (legal persons) using data
###   from 'Yahoo! Finance'
### Aliases: find.firms

### ** Examples

# Registering Apple, General Motors, and British American Tobacco automatically
#| Results are subject to the correct functioning of the package `yahoofinancer`
#| and of the Yahoo! Finance API




cleanEx()
nameEx("find.people")
### * find.people

flush(stderr()); flush(stdout())

### Name: find.people
### Title: Extract all the unique people associated to at least one of the
###   provided 'firm' objects
### Aliases: find.people

### ** Examples

# Find all the shareholders in companies that Berkshire Hathaway holds
data('firms_BKB')
shareholders <- find.people(firms_BKB, who = 'own')

# Find all those managing the companies that Berkshire Hathaway holds
data('firms_BKB')
managers <- find.people(firms_BKB, who = 'man')




cleanEx()
nameEx("network.efficiency")
### * network.efficiency

flush(stderr()); flush(stdout())

### Name: network.efficiency
### Title: Calculate network efficiency
### Aliases: network.efficiency

### ** Examples

# Load some data
data('firms_BKB')

# Create a FF matrix
mat <- FF(firms_BKB, who = 'b', ties =  'n')
# Use the built-in Floyd-Warshall algorithm
network.efficiency(mat, use.igraph = FALSE)

#' # Create a FF graph
if(!require('igraph')){
  g <- FF.graph(mat, 'simple')
  # Use igraph's implementation, which gives the same result
  # as the built-in Floyd-Warshall algorithm, but is faster
  network.efficiency(g, use.igraph = TRUE)==network.efficiency(mat, use.igraph = FALSE)
}




cleanEx()
nameEx("query.firm")
### * query.firm

flush(stderr()); flush(stdout())

### Name: query.firm
### Title: Function to extract information from a 'firm' object (legal
###   person)
### Aliases: query.firm

### ** Examples





cleanEx()
nameEx("query.firms")
### * query.firms

flush(stderr()); flush(stdout())

### Name: query.firms
### Title: Function to extract information from multiple 'firm' object
###   (legal person)
### Aliases: query.firms

### ** Examples





cleanEx()
nameEx("query.firms.dataframe")
### * query.firms.dataframe

flush(stderr()); flush(stdout())

### Name: query.firms.dataframe
### Title: Function to extract information from multiple 'firm' object
###   (legal person) as a data frame
### Aliases: query.firms.dataframe

### ** Examples





cleanEx()
nameEx("register.firm")
### * register.firm

flush(stderr()); flush(stdout())

### Name: register.firm
### Title: Function to create a 'firm' (legal person)
### Aliases: register.firm

### ** Examples


# Registering Apple manually
AAPL <- register.firm(name = 'Apple', id = 'AAPL', legal_form = 'GmbH',
                      revenues = 81665400000, capitalisation = 2755039000000,
                      management = my_vector <- c("Timothy D. Cook",
                                                  "Luca Maestri",
                                                  "Jeffrey E. Williams",
                                                  "Katherine L. Adams",
                                                  "Deirdre O'Brien",
                                                  "Chris Kondo",
                                                  "James Wilson",
                                                  "Mary Demby",
                                                  "Nancy Paxton",
                                                  "Greg Joswiak"),
                      ownership = c('Vanguard Total Stock Market Index Fund',
                      'Vanguard 500 Index Fund',
                      'Fidelity 500 Index Fund',
                      'SPDR S&P 500 ETF Trust',
                      'iShares Core S&P 500 ETF',
                      'Invesco ETF Tr-Invesco QQQ Tr, Series 1 ETF',
                      'Vanguard Growth Index Fund',
                      'Vanguard Institutional Index Fund-Institutional Index Fund',
                      'Vanguard Information Technology Index Fund',
                      'Select Sector SPDR Fund-Technology'),
                      shares = c(0.0290, 0.0218, 0.0104, 0.0102, 0.0084,
                                 0.0082, 0.0081, 0.0066, 0.0043, 0.0039),
                      currency = 'USD')

# Registering a coal-mining company indicating the sector using `NACE` codes, without ID
set.seed(123456789)
firm_coalmining <- register.firm(
  name = 'A coal-mining firm',
  legal_form = 'Private',
  sector = 'B.05',
  sector_classif = 'NACE'
)

# Getting creative: Register a firm with coded owners and managers
set.seed(123456789)
firm_coded <- register.firm(
  name = 'Coded firm',
  revenues = sample(seq(1:100)/10, 1)*10^sample(1:5, 1),
  capitalisation = sample(seq(1:100)/10, 1)*10^sample(2:7, 1),
  management = c('Board Member', 'CEO', 'CTO', 'Activist investor'),
  ownership = c('State', 'Foreign investors'),
  shares = c(51, 49),
  currency = 'EUR'
)




### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
