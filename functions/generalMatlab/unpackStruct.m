function [fieldNames]=unpackStruct(inputStruct)

% unpackStruct 
% This function simply takes the struct you pass as an argument and assigns
% all of it's constituent variables in the workspace, outside of the
% struct. The original struct remains.
%
% inputs: one structure
% outputs: fieldNames is an optional list of fields in the struct
%
% be careful with this it will overwrite like name variables.
% todo: give user option to use the fieldNames to confirm any possible
% overwrites in the workspace.
%


tSt=inputStruct;
fieldNames=fieldnames(tSt);

for n=1:numel(fieldNames)
    eval(['tempVar=tSt.' fieldNames{n} ';']);
    assignin('base',fieldNames{n},tempVar);
end

    
end

% v1.0 - 6/22/2017 - Chris Deister - cdeister@brown.edu for ?s
% anything I write, trivial or not, is intended for scientific or creative
% efforts and for anyone else to use as they see fit. MIT license for
% anyting that needs it (here because journals are asking more)