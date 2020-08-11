trigger parenttochild on Contact (after insert) {
 
        
            if (trigger.isInsert)
            {
                 ptocauto.updatefield(trigger.new);
            }
       
}