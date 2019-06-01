package main

import (
	"fmt"
	"github.com/antlr/antlr4/runtime/Go/antlr"
	"github.com/djhaskin987/mtn/listener"
	"github.com/djhaskin987/mtn/parser"
	"io/ioutil"
)

func showLexer(instr string) {
	// Setup the input
	is := antlr.NewInputStream(instr)

	// Create the Lexer
	lexer := parser.NewMTNLexer(is)

	// Read all tokens
	for {
		t := lexer.NextToken()
		if t.GetTokenType() == antlr.TokenEOF {
			break
		}
		fmt.Printf("%s (%q)\n",
			lexer.SymbolicNames[t.GetTokenType()], t.GetText())
	}
}

func tryParser(instr string) {

	// Setup the input
	is := antlr.NewInputStream(instr)

	// Create the Lexer
	lexer := parser.NewMTNLexer(is)
	stream := antlr.NewCommonTokenStream(lexer, antlr.TokenDefaultChannel)

	// Create the Parser
	p := parser.NewMTNParser(stream)

	// Finally parse the expression
	antlr.ParseTreeWalkerDefault.Walk(&listener.MTNListener{}, p.Mtn_parse())
}

func main() {
	in, err := ioutil.ReadFile("./example.mtn")
	if err != nil {
		panic("Problem reading in file")
	}
	instr := string(in)
	showLexer(instr)
	tryParser(instr)
}
