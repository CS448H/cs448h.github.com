---
layout: post
title: CS448H - domain-specific languages for graphics, imaging, and beyond
---

Lecture Schedule
--------

TTh 1:30--2:50 in Gates 392

### 9/22 -- Introduction

* [Slides](intro.pdf)

Readings:

* [J Bentley. _Little Languages_](little-languages.pdf)
* [P Hudak. _Domain Specific Languages_](DSEL-Little.pdf)

Please take the [course survey](http://goo.gl/forms/kJ4qicMhrq).

### 9/24 -- Overview

* [Slides](build.pdf)
* Example code: [calc1.py](calc1.py), [calc2.py](calc2.py)

Readings:

* [M. Fowler & T. White. _Domain-Specific Languages_](http://proquest.safaribooksonline.com/9780132107549?uicode=stanford)


### 9/29 -- Introduction to Lua

* [Slides](cs448h-3.pdf)
* [R. Ierusalimschy, L. Henrique de Figueiredo, & W.  Celes. _The Evolution of Lua_](http://www.lua.org/doc/hopl.pdf)
* [R. Ierusalimschy, L. Henrique de Figueiredo, & W.  Celes. _Passing a Language through the Eye of a Needle_](https://queue.acm.org/detail.cfm?id=1983083)
* [Example Code From Today](example-1.lua)

### 10/1 -- Introduction to Terra

* [Slides](cs448h-4.pdf)
* [Z. DeVito & P. Hanrahan. _The Design of Terra: Harnessing the best features of high-level and low-level languages_](http://terralang.org/snapl-devito.pdf)
* [Z. DeVito, J. Hegarty, A. Aiken, P. Hanrahan, & J. Vitek. _Terra: A Multi-Stage Language for High-Performance Computing_](http://terralang.org/pldi071-devito.pdf)
* [Example Code From Today](example-2.t), [Example Image](giraffe.ppm)

### Assignment 1 - _due 10/13_
Assignment 1 is to build a compiler for regular expressions using Lua and Terra. The starter code and assignment description is [in the course GitHub org](http://github.com/CS448H/assignment1). When you're ready to start, start the template repo for your submission by following [this invite link](https://classroom.github.com/assignment-invitations/349e75dcf83aeebb9c0fefbc62a42dbf) (you'll need to be logged into your GitHub account).

#### Update: Assignment 1 reference solution
The repository is now private, but if you're logged in as yourself on GitHub you can see the reference solution to assignment 1 as [REFregex.t](https://github.com/CS448H/assignment1/blob/master/REFregex.t).

### 10/6 -- Designing intermediate representations

* [Slides](IRs.pdf)

### 10/8 -- IR design, transformations, and code generation

* [Slides](IRs-transforms-codegen.pdf)
* [Expression language example code](http://github.com/CS448h/cs448h.github.com/tree/master/ir-codegen-example)

### 10/15 -- How to read a research paper

Read the following paper on Halide.

Think about it critically using the web site on critical thinking as a guide.
What are the goals of the work, what is the specific problem being solved,
what are the assumptions behind the work,
are there new concepts or algorithms in the paper,
what is the proposed solution,
what evidence is given that the solution works,
what interpretation or inference is done in support of the conclusions,
and finally, what are the implications and consequences of this research.
Pat will lead a discussion of the paper in class.
Be prepared to orally answer the above questions.
Consult the guide for additional questions that might pertain
to this work.

* [Jonathan Ragan-Kelley, Andrew Adams, Sylvain Paris, Marc Levoy, Saman Amarasinghe, Frédo Durand.  _Decoupling Algorithms from Schedules for Easy Optimization of Image Processing Pipelines_](http://people.csail.mit.edu/jrk/halide12/)
* [Concise guide to critical thinking](http://www.criticalthinking.org/ctmodel/logic-model1.htm). 

### Assignment 2 - _due 10/27_
Assignment 2 walks you through the process of optimizing an image processing language through IR design and transformations. The  starter code is availiable [on the course github page](http://github.com/CS448H/assignment2). When you are ready to get started follow [this invite link](https://classroom.github.com/assignment-invitations/41ab15b18322a502c54d69925a70cf0b).

### 10/20 -- Halide, Jonathan Ragan-Kelley
* [Slides](2015-10-20-halide.pdf)
* [The Halide project](http://halide-lang.org)
* The second Halide paper: [Jonathan Ragan-Kelley, Connelly Barnes, Andrew Adams, Sylvain Paris, Frédo Durand, Saman Amarasinghe. _Halide: a language and compiler for optimizing parallelism, locality, and redundant computation in image processing pipelines_](http://people.csail.mit.edu/jrk/halide-pldi13.pdf)

### 10/22 -- Final Project Brainstorming
Great work on your own ideas and discussion during class! Our initial suggestions are [here](2015-10-22-project-ideas.pdf).

### 10/27 -- Guest lecture: Shading Languages, Tim Foley, NVIDIA
* [Tim Foley, Pat Hanrahan. _Spark: Modular, Composable Shaders for Graphics Hardware_](http://graphics.stanford.edu/papers/spark/)

### 10/29 -- Guest lecture: Simulation Languages, Gilbert Bernstein
* [Gilbert Louis Bernstein, Chinmayee Shah, Crystal Lemire, Zachary DeVito, Matthew Fisher, Philip Levis, Pat Hanrahan. _Ebb: A DSL for Physical Simulation on CPUs and GPUs_](http://arxiv.org/abs/1506.07577)
* [Fredrik Kjolstad, Shoaib Kamil, Jonathan Ragan-Kelley, David I.W. Levin, Shinjiro Sueda, Desai Chen, Etienne Vouga, Danny M. Kaufman, Gurtej Kanwar, Wojciech Matusik, Saman Amarasinghe. _Simit: A Language for Physical Simulation_](http://dspace.mit.edu/handle/1721.1/97075)

### 11/10 -- Guest lecture: Torch, Ronan Collobert, Facebook

### 11/12 -- Initial Project Proposals 

### 11/17 -- Debate

### 12/3 -- Final Project Presentations

### 12/8 -- Final Project Paper Due
