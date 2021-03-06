

# Load Packages -----------------------------------------------------------

library(tidyverse)
library(ggrepel)
library(performance)

# Read Data ---------------------------------------------------------------


file_url<-"https://esajournals.onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1002%2Fecy.2647&file=ecy2647-sup-0001-DataS1.zip"
file_name <- basename(file_url)

if (!dir.exists("bird_data")) dir.create("bird_data")

#if (!file.exists(file_name))
download.file(file_url, destfile = "bird_data/bird_data.zip", mode = "wb")
unzip("bird_data/bird_data.zip", overwrite = TRUE, exdir = "bird_data")

#reading and renaming data
bird_data<-read_csv("bird_data/ATLANTIC_BIRD_TRAITS_completed_2018_11_d05.csv")


# Clean Up Data -----------------------------------------------------------


#renaming variables 
bird_data <- rename(bird_data, 
                    body_mass_g = Body_mass.g., 
                    body_length_mm = Body_length.mm., 
                    altitude = Altitude, 
                    wing_length_mm = Wing_length.mm.
                    )

#add new variable
length_vs_mass <- select(bird_data, body_length_mm, body_mass_g)

length_vs_mass <- mutate(bird_data, 
                         length_mass_ratio = body_length_mm / body_mass_g)


# Plots -------------------------------------------------------------------


#testing for normal distribution of length_mass_ratio
ggplot(data = length_vs_mass) +
  geom_histogram(mapping = aes(
    x = length_mass_ratio), bins = 50, boundary = 0)
 

#ggplot Length Mass Ratio vs Altitude
ggplot(data = length_vs_mass) +
  geom_point(mapping = aes(
    y = length_mass_ratio, 
    x = altitude)
  )

#ggplot Length Mass Ratio vs Altitude (color) 
ggplot(data = length_vs_mass) +
  geom_point(mapping = aes(
    y = length_mass_ratio, 
    x = altitude, 
    color = Order), 
    alpha = 0.1
  )

#facet wrap graph by order
ggplot(data = length_vs_mass) +
  geom_point(mapping = aes(
    x = length_mass_ratio, 
    y = altitude))+
  facet_wrap(~Order)


# ln of Data ----------------------------------------------------------

#log of length_mass_ratio to correct right skew 
length_vs_mass <-mutate(length_vs_mass, ln_lmr = log(length_mass_ratio))

#testing for normal distribution of length_mass_ratio
ggplot(data = length_vs_mass) +
  geom_histogram(mapping = aes(
    x = ln_lmr), bins = 100) 
  

#testing for normal distribution of length_mass_ratio
ggplot(data = length_vs_mass) +
  geom_histogram(mapping = aes(
    x = ln_lmr), bins = 100) + 
  facet_wrap(~Order,scales = "free_y")


# Length Mass (lmr) Plots ---------------------------------------------------

#length mass plot of Anseriformes 
length_vs_mass %>% 
  filter(Order=="Anseriformes") %>% 
  ggplot() +
  geom_point(mapping = aes(
    x = body_length_mm, 
    y = body_mass_g)
  )

#length mass plot for Passeriformes
length_vs_mass %>% 
  filter(Order=="Passeriformes") %>% 
  ggplot() +
  geom_point(mapping = aes(
    x = body_length_mm, 
    y = body_mass_g)
  )

#length mass ratio vs altitude Passeriformes
length_vs_mass %>% 
  filter(Order=="Passeriformes") %>% 
  ggplot() +
  geom_point(mapping = aes(
    x = length_mass_ratio, 
    y = altitude)
  )

#length mass ratio vs altitude Anseriformes
length_vs_mass %>% 
  filter(Order=="Anseriformes") %>% 
  ggplot() +
  geom_point(mapping = aes(
    x = length_mass_ratio, 
    y = altitude)
  )

#ln_lmr vs altitude for Anseriformes
length_vs_mass %>% 
  filter(Order=="Anseriformes") %>% 
  ggplot() +
  geom_point(mapping = aes(
    x = ln_lmr, 
    y = altitude)
  )

#ln_lmr vs altitude for Passeriformes
length_vs_mass %>% 
  filter(Order=="Passeriformes") %>% 
  ggplot(mapping = aes(
    y = ln_lmr, 
    x = altitude)) +
  geom_point() +
  geom_smooth(method = "loess")


# Passeriformes Mean Data -------------------------------------------------

#fit line with altitude > 1000 Passeriformes
length_vs_mass %>% 
  filter(Order=="Passeriformes",
         altitude >= 1000) %>% 
  ggplot(mapping = aes(
    y = ln_lmr, 
    x = altitude)) +
  geom_point(mapping = aes(color = Family)) +
  geom_smooth(method = "loess") +
  geom_text_repel(
    mapping = aes(label = Family), 
    data = length_vs_mass %>% 
      filter(Order=="Passeriformes",
             altitude >= 2000)
  )

# fit line of passeriformes: furnariidea altitude >1000 (color)
length_vs_mass %>% 
  filter(Order=="Passeriformes",
         Family=="Furnariidae",
         altitude >= 1000) %>% 
  ggplot(mapping = aes(
    y = ln_lmr, 
    x = altitude)) +
  geom_point(mapping = aes(color = Species)) +
  geom_smooth(method = "lm")

#fit line of passeriformes: furnariidea altitude >1000 
length_vs_mass %>% 
  filter(
    Order=="Passeriformes",
    Family=="Furnariidae",
    altitude > 1000
  ) %>% 
  ggplot(mapping = aes(
    y = ln_lmr, 
    x = altitude)) +
  geom_point() +
  geom_smooth(method = "lm")

# frequency distribution of mean ln_lmr in passeriformes
length_vs_mass %>% 
  filter(Order == "Passeriformes")%>% 
  group_by(Order, Family, Genus, Species) %>% 
  summarize(ln_lmr = mean(ln_lmr),
            altitude = mean(altitude)) %>% 
  ggplot() +
  geom_histogram(aes(x = ln_lmr))

#mean of ln_lmr vs altitude 
length_vs_mass %>% 
  group_by(Order, Family, Genus, Species) %>% 
  summarize(ln_lmr = mean(ln_lmr),
            altitude = mean(altitude)) %>% 
  ggplot(mapping = aes(
    y = ln_lmr, 
    x = altitude)) +
  geom_point() +
  geom_smooth(method = "lm")

#mean of ln_lmr vs altitude 
length_vs_mass %>% 
  filter(Genus == "Turdus") %>% 
  ggplot(mapping = aes(
    y = ln_lmr, 
    x = altitude,
    color = Species)) +
  geom_point() +
  geom_smooth(method = "lm") +
  xlim(c(0,1700))

#mean of ln_lmr vs altitude 
length_vs_mass %>% 
  filter(Genus == "Turdus") %>% 
  group_by(Species) %>% 
  summarize(lmr = mean(length_mass_ratio, na.rm=TRUE),
            altitude = mean(altitude, na.rm=TRUE)) %>% 
  ggplot(mapping = aes(
    y = ln_lmr, 
    x = altitude)) +
  geom_point(aes(color = Species), size=5) +
  geom_smooth(method = "lm")

#table of mean_ln_lmr and mean_altitude passeriformes
passeriformes_means<-
  length_vs_mass %>% 
  filter(!is.na(altitude), !is.na(ln_lmr)) %>% 
  group_by(Order, Family, Genus, Species) %>% 
  summarize(
    ln_lmr = mean(ln_lmr),
    altitude = mean(altitude)
  ) %>% 
  print()


# T-Tests -----------------------------------------------------------------

#filter smaller and larger means

mean_hilo <-
  passeriformes_means %>% 
  mutate(hilo = ifelse(altitude>1000, "Above 1000 m", "Below 1000 m")) %>% 
  group_by(hilo) %>% 
  summarize(
    mean = mean(ln_lmr),
    # sd = sd(ln_lmr, na.rm = TRUE),
    # sem = sd(ln_lmr)/sqrt(n()),
    # upper = ln_lmr + 2*sem,
    # lower = ln_lmr - 2*sem
  )

passeriformes_means %>% 
  mutate(hilo = ifelse(altitude>1000, "Above 1000 m", "Below 1000 m")) %>%
  ggplot(aes(x = ln_lmr)) +
  geom_histogram() +
  geom_vline(aes(xintercept = mean), data = mean_hilo,
             linetype = "dashed", size = 2, color = "red") +
  facet_wrap(~ hilo, ncol = 1, scales = "free_y")

passeriformes_means %>% 
  mutate(hilo = ifelse(altitude>1000, "Above 1000 m", "Below 1000 m")) %>% 
  t.test(ln_lmr ~ hilo, data = .)


# Antilog of Means --------------------------------------------------------

#antilog of hi
exp(2.067247)

#antilog of low
exp(1.647261)



-----------------------------------------------------------------
  NEW STUFF
-----------------------------------------------------------------

# Wing Length ---------------------------------------------------

#testing for normal distribution of wing length
ggplot(data = length_vs_mass) +
  geom_histogram(mapping = aes(
    x = wing_length_mm), bins = 50, boundary = 0)

#log of wing_length_mm to correct right skew 
length_vs_mass <-mutate(length_vs_mass, ln_wings = log(wing_length_mm))


#Wing Length log ------------------------------------------------

#testing for normal distribution of ln_wings
ggplot(data = length_vs_mass) +
  geom_histogram(mapping = aes(
    x = ln_wings), bins = 100)

#testing for normal distribution of ln_wings (all orders)
ggplot(data = length_vs_mass) +
  geom_histogram(mapping = aes(
    x = ln_wings), bins = 100)+ 
  facet_wrap(~Order)


#Wing Length vs Altitude ----------------------------------------

#ggplot Wing Length vs Altitude
ggplot(data = bird_data) +
  geom_point(mapping = aes(
    y = wing_length_mm,
    x = altitude))

#ggplot Wing Length vs Altitude (color)
ggplot(data = bird_data) +
  geom_point(mapping = aes(
    y = wing_length_mm,
    x = altitude,
    color = Order),
    alpha = 0.4)

#wing length vs altitude Passeriformes
length_vs_mass %>% 
  filter(Order=="Passeriformes") %>% 
  ggplot() +
  geom_point(mapping = aes(
    x = wing_length_mm, 
    y = altitude)
  )

#mean of ln_lmr vs altitude (Turdus) 
length_vs_mass %>% 
  filter(Genus == "Turdus") %>% 
  ggplot(mapping = aes(
    y = ln_wings, 
    x = altitude,
    color = Species)) +
  geom_point() +
  geom_smooth(method = "lm") +
  xlim(c(0,1700))


# Geom smooth Wings--------------------------------------------------

#geom smooth ln_wings vs altitude
length_vs_mass %>% 
  filter(
    Order=="Passeriformes",
    Family=="Furnariidae",
  ) %>% 
  ggplot(mapping = aes(
    y = ln_wings, 
    x = altitude)) +
  geom_point() +
  geom_smooth(method = "lm")

#geom smooth ln_wings above 1000m
length_vs_mass %>% 
  filter(
    Order=="Passeriformes",
    Family=="Furnariidae",
    altitude > 1000
  ) %>% 
  ggplot(mapping = aes(
    y = ln_wings, 
    x = altitude)) +
  geom_point() +
  geom_smooth(method = "lm")


#Fit Lines (wings) ---------------------------------------------------

#fit line of passeriformes: furnariidea wings
length_vs_mass %>% 
  filter(
    Order=="Passeriformes",
    Family=="Furnariidae",
  ) %>% 
  ggplot(mapping = aes(
    y = ln_wings, 
    x = altitude)) +
  geom_point() +
  geom_smooth(method = "lm")


#fit line of passeriformes: furnariidae altitude >1000 wings
length_vs_mass %>% 
  filter(
    Order=="Passeriformes",
    Family=="Furnariidae",
    altitude > 1000
  ) %>% 
  ggplot(mapping = aes(
    y = ln_wings, 
    x = altitude)) +
  geom_point() +
  geom_smooth(method = "lm")


#Bill Length vs Altititude ------------------------------------------------

#rename data
length_vs_mass <- rename(length_vs_mass, 
                    bill_length = Bill_length.mm.)


#log of bill length
length_vs_mass <-mutate(length_vs_mass, ln_bills = log(bill_length))

#testing for normal distribution of Bill Length (all orders)
ggplot(data = length_vs_mass) +
  geom_histogram(mapping = aes(
    x = bill_length), bins = 100)+ 
  facet_wrap(~Order)

#ggplot Bill Length vs Altitude (color)
ggplot(data = bird_data) +
  geom_point(mapping = aes(
    y = bill_length,
    x = altitude,
    color = Order),
    alpha = 0.4)


#geom smooth ln_bills vs altitude
length_vs_mass %>% 
  filter(
    Order=="Passeriformes",
    Family=="Furnariidae",
  ) %>% 
  ggplot(mapping = aes(
    y = ln_bills, 
    x = altitude)) +
  geom_point() +
  geom_smooth(method = "lm")


#QQ Plot -------------------------------------------------------

#creating fit

fit <- lm(ln_bills~altitude, data=length_vs_mass)

# testing for non-normality

check_model(fit)

