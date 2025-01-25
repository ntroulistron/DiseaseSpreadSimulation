globals [
  infected-count
  healthy-count
  recovered-count
  total-infections
  total-recoveries
  average-recovery-time
  recovery-times
]

turtles-own [state recovery-timer stage-timer]

to setup
  clear-all

  ;; Set background color
  ask patches [
    set pcolor gray + 2
  ]

  ;; Initialize statistics
  set infected-count 0
  set healthy-count 0
  set recovered-count 0
  set total-infections 0
  set total-recoveries 0
  set average-recovery-time 0
  set recovery-times []

  ;; Create turtles
  create-turtles population [
    setxy random-xcor random-ycor
    set state "healthy"
    set color green  ;; Healthy turtles are green
    set shape "person"  ;; Use person shape for better visualization
  ]

  ;; Infect initial turtles
  ask n-of initial-infected turtles [
    set state "infected"
    set color red
    set recovery-timer 30
    set stage-timer 15
  ]

  update-counts
  reset-ticks
end

to go
  ;; Divide turtles into two groups
  let group1 turtles with [who mod 2 = 0]  ;; Even-numbered turtles
  let group2 turtles with [who mod 2 = 1]  ;; Odd-numbered turtles

  ;; Process group1 tasks
  ask group1 [
    if state = "healthy" [ avoid-infected ]
    if state = "infected" [ spread-disease ]
  ]

  ;; Process group2 tasks
  ask group2 [
    if state = "mild" [ progress-to-severe ]
    if state = "severe" [ progress-to-outcome ]
    move
  ]

  ;; Show infection radius if enabled
  visualize-infection-radius

  ;; Update counts and visuals
  update-counts

  ;; Slow down simulation
  wait 0.2  ;; Adjust this value for speed

  tick
end


to spread-disease
  ;; Spread disease to healthy turtles nearby
  ask turtles with [state = "infected"] [
    let nearby-healthy turtles in-radius infection-radius with [state = "healthy"]
    ask nearby-healthy [
      if random-float 1 < infection-probability [
        set state "mild"
        set color yellow
        set recovery-timer 30
        set stage-timer 15
      ]
    ]
  ]
end

to avoid-infected
  ;; Healthy turtles avoid infected ones
  let nearby-infected turtles in-radius infection-radius with [state = "infected"]
  if any? nearby-infected [
    let away-direction towards one-of nearby-infected
    set heading away-direction + 180  ;; Move away from infected turtle
    forward 1
  ]
end

to progress-to-severe
  ;; Change from mild to severe
  set stage-timer stage-timer - 1
  if stage-timer <= 0 [
    set state "severe"
    set color orange
  ]
end

to progress-to-outcome
  ;; Recover or die
  set recovery-timer recovery-timer - 1
  if recovery-timer <= 0 [
    if random-float 1 < 0.2 [  ;; 20% chance of death
      set state "dead"
      set color gray
      stop
    ]
    set state "recovered"
    set color blue
    set recovery-times lput (30 - recovery-timer) recovery-times
  ]
end

to move
  ;; Turtles move randomly
  right random 90 - 45
  forward 1.5
end

to visualize-infection-radius
  ;; Highlight infection radius if enabled
  if show-infection-radius [
    ask patches [
      if pcolor = red - 2 [ set pcolor gray + 2 ]  ;; Reset background color
    ]

    ask turtles with [state = "infected"] [
      ask patches in-radius infection-radius [
        set pcolor red - 2  ;; Highlight patches within infection radius
      ]
    ]
  ]
  ;; Clear highlights if disabled
  if not show-infection-radius [
    ask patches [
      if pcolor = red - 2 [ set pcolor gray + 2 ]  ;; Reset background color
    ]
  ]
end

to update-counts
  ;; Update counts for each state
  set infected-count count turtles with [state = "mild" or state = "severe" or state = "infected"]
  set healthy-count count turtles with [state = "healthy"]
  set recovered-count count turtles with [state = "recovered"]

  ;; Update recovery statistics
  set total-recoveries count turtles with [state = "recovered"]
  if not empty? recovery-times [
    set average-recovery-time mean recovery-times
  ]

  ;; Update plots
  set-current-plot "Healthy Population"
  set-current-plot-pen "Healthy"
  plot healthy-count

  set-current-plot "Infected Population"
  set-current-plot-pen "Infected"
  plot infected-count

  set-current-plot "Recovered Population"
  set-current-plot-pen "Recovered"
  plot recovered-count
end
@#$#@#$#@
GRAPHICS-WINDOW
935
20
1473
559
-1
-1
16.061
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
41
89
114
131
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
136
87
205
130
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
35
249
212
282
population
population
10
500
500.0
1
1
NIL
HORIZONTAL

SLIDER
35
295
212
328
initial-Infected
initial-Infected
1
50
50.0
1
1
NIL
HORIZONTAL

MONITOR
236
60
384
105
healthy
healthy-count
17
1
11

MONITOR
392
60
540
105
infected
infected-count
17
1
11

MONITOR
237
213
385
258
recover
recovered-count
17
1
11

PLOT
549
10
928
265
Healthy Population
Time
Count of healthy turtles
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Healthy" 1.0 0 -10899396 true "" "plot count turtles"

PLOT
553
270
931
593
Infected Population
Time
Count of infected turtles
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Infected" 1.0 0 -2674135 true "" "plot count turtles"

PLOT
232
267
549
595
Recovered Population
Time
Count of recovered turtles
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Recovered" 1.0 0 -13345367 true "" "plot count turtles"

SLIDER
33
158
213
191
infection-radius
infection-radius
0.5
5
4.5
0.5
1
NIL
HORIZONTAL

SLIDER
35
203
212
236
infection-probability
infection-probability
0
1
0.5
0.5
1
NIL
HORIZONTAL

SWITCH
30
369
209
402
show-infection-radius
show-infection-radius
1
1
-1000

MONITOR
392
213
540
258
Average Recovery Time
average-recovery-time
17
1
11

@#$#@#$#@
## WHAT IS IT?

This model simulates the dynamics of a disease spreading through a population. Each turtle represents an individual, interacting and moving randomly within the environment. The model includes:
1. Stages of disease progression (healthy, infected, mild, severe, recovered, dead).
2. Adjustable parameters for infection radius, probability, and population size.
3. A simulated multi-threading approach, where turtles are divided into two groups (even vs. odd identifiers) and processed in separate steps within each tick. This mimics parallel processing within NetLogo's single-threaded environment.


## HOW IT WORKS

1. **Healthy (Green):** Individuals start healthy and uninfected.
2. **Infected (Red):** Initial cases spread the disease to others nearby.
3. **Mild (Yellow):** Infected turtles develop mild symptoms.
4. **Severe (Orange):** Mild cases progress to severe symptoms over time.
5. **Recovered (Blue):** Recovered turtles become immune to further infection.
6. **Dead (Gray):** Some turtles die if their condition worsens.

To simulate multi-threading, the turtles are divided into two groups based on their unique identifiers (who mod 2). Each group is assigned specific tasks:

Group 1 (Even-numbered turtles): Handles infection spreading and avoidance of infected turtles.
Group 2 (Odd-numbered turtles): Handles disease progression and random movement.
These groups are processed sequentially within each tick, creating the appearance of parallelism.

## HOW TO USE IT

#### Controls:
1. **Buttons:**
   - `Setup`: Initializes the simulation with the specified population and infection settings.
   - `Go`: Starts or stops the simulation.
2. **Sliders:**
   - `Population`: Number of individuals in the simulation.
   - `Initial-Infected`: Number of individuals starting as infected.
   - `Infection-Radius`: The distance within which infection spreads.
   - `Infection-Probability`: Probability of infection during contact.
3. **Switches:**
   - `Show Infection Radius`: Toggles visualization of the infection radius around infected turtles.

#### Steps to Run:
1. Set the desired parameters using the sliders and switch.
2. Click `Setup` to create the population.
3. Click `Go` to start the simulation.
4. Observe how the disease spreads and monitor the plots and monitors for insights.

---

### PARAMETERS
1. **Population**:
   - Larger populations result in more interactions and faster spread.
2. **Initial-Infected**:
   - A higher number of initial infections leads to faster disease outbreaks.
3. **Infection-Radius**:
   - A larger radius increases the spread range of the disease.
4. **Infection-Probability**:
   - Higher probabilities increase the likelihood of transmission when turtles are in contact.

## THINGS TO NOTICE

Observe how the multi-threading simulation impacts the behavior of agents. Tasks are distributed among groups to reduce computational load in each step, improving clarity and mimicking parallel processing.

## THINGS TO TRY

1. **Experiment with Parameters:**
   - Reduce the infection probability to simulate social distancing.
   - Increase the infection radius to simulate more contagious diseases.
   - Start with a smaller number of initial infections to observe slower outbreaks.
2. **Dynamic Adjustments:**
   - Change the infection radius or probability during the simulation and see the impact.
3. **Observe Behavior:**
   - Toggle the `Show Infection Radius` switch to visualize infection zones.

## EXTENDING THE MODEL

1. **Quarantine Zones:**
   - Add areas where infected turtles are isolated to slow disease spread.
2. **Vaccination:**
   - Introduce a mechanism to vaccinate turtles, making them immune.
3. **Weather Effects:**
   - Simulate weather changes that affect the spread (e.g., rain slowing movement or increasing infection radius).
4. **Different Diseases:**
   - Simulate multiple diseases with different transmission and recovery dynamics.

## CREDITS AND REFERENCES

This model was developed using NetLogo (Wilensky, 1999). For further details on the functionalities and usage of NetLogo, refer to the NetLogo User Manual.

## CITATION

Wilensky, U. (1999). NetLogo. Center for Connected Learning and Computer-Based Modeling, Northwestern University. Evanston, IL. http://ccl.northwestern.edu/netlogo/
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
