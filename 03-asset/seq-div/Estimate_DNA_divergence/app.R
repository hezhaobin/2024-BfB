#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)

# Define functions for simulating evolution
mutate <- function(seq){
  ### procedure to mutate the sequence in each generation
  L <- length(seq)
  S <- sample(1:L, 1) # pick the sites to mutate 
  m <- seq[S] + sample(1:3, 1, T) # this adds a random integer between 1-3 to the original value.
  seq[S] <- m %% 4 # this will take anything greater than 3 to "circle back"
  return(seq)
}

evolve <- function(seq, N){
  ### throw N mutations
  seqs <- list(seq) # record the genotype of each generation
  Nobs <- 0   # counter for the number of *observed* mutations
  for( i in 1:N ){
    seq <- mutate(seq) # perform mutation
    seqs <- c(seqs, list(seq)) # record the genotype at this generation
    Nobs <- c(Nobs, sum(seqs[[1]] != seq)) # this records the number of *observed* mutations
  }
  return(list(s = seqs, realized = 0:N, observed = Nobs))
}

printSeq <- function(seq){
  return(paste0(c("A", "C", "G", "T")[seq+1], collapse = ""))
}

printAlign <- function(seqs){
  original <- c("A", "C", "G", "T")[seqs[[1]]+1]
  final <- c("A", "C", "G", "T")[seqs[[length(seqs)]]+1]
  align <- ifelse(final == original, ".", final)
  s0 <- paste(original, collapse = "")
  s1 <- paste(align, collapse = "")
  return(paste(s0, s1, sep = "\n"))
}

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Demonstrate DNA sequence divergence"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            sliderInput("seqL",
                         "Sequence length (nt):",
                         min = 1,
                         max = 200,
                         value = 50),
            numericInput("mutN",
                         "Number of mutations:",
                         min = 0,
                         value = 30,
                         step = 5),
            actionButton("refresh", "Recalculate")
        ),

        # Show a plot of the generated distribution
        mainPanel(
          p("The following alignment shows the final sequence (bottom) in relation to the original (top)."),
          verbatimTextOutput("align"),
          em("Number of actual mutations:"),
          textOutput("real"),
          em("Number of observed mutations:"),
          textOutput("obs"),
          em("Corrected # of mutations (Jukes-Cantor):"),
          textOutput("corr"),
          plotOutput("relation")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  # define initial sequence
  s = sample(0:3, size = 200, replace = TRUE)
  
  # reactive expression to re-execute the mutation experiment when seq length or # mutation parameters change
  dataInput <- reactive({
    input$refresh # simply by accessing the input$refresh button makes this chunk dependent on it
    seq <- s[1:input$seqL]
    evolve(seq, input$mutN)
  })
  
  output$align = renderPrint({
    seqs <- dataInput()$s
    original <- c("A", "C", "G", "T")[seqs[[1]]+1]
    final <- c("A", "C", "G", "T")[seqs[[length(seqs)]]+1]
    align <- ifelse(final == original, ".", final)
    s0 <- paste(original, collapse = "")
    s1 <- paste(align, collapse = "")
    cat(paste(s0, s1, sep = "\n"))
  })
  
  output$real <- renderText({ input$mutN })
  
  output$obs <- renderText({
    tmp <- dataInput()
    last(tmp$observed)
  })
  
  output$corr <- renderText({
    tmp <- dataInput()
    obs <- last(tmp$observed)
    L <- input$seqL
    c <- -3/4*log(1-4/3*obs/L)
    K <- c*L
  })
  output$relation <- renderPlot({
    tmp <- dataInput()
    plot(tmp$realized, tmp$observed, type = "b", xlab = "Actual # of mutations", ylab = "Observed # of mutations")
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
