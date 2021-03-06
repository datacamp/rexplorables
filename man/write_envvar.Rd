% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{write_envvar}
\alias{write_envvar}
\title{Write environment variable}
\usage{
write_envvar(..., file = "/etc/R/Renviron")
}
\arguments{
\item{...}{environment variables to copy}

\item{file}{path to environment file to copy the variables to}
}
\description{
This lets environment authors set environment variables in requirements.R
that get copied over to the course image, and available to all exercises
}
\examples{
\dontrun{
  write_envvar(DC_SHINY = "1")
}
}
