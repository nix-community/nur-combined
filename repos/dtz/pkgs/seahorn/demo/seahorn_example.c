extern void __VERIFIER_assume (int);                                                                                    
extern void __VERIFIER_error (void);                                                                                    
void assert (int v) { if (!v) __VERIFIER_error (); }                                                                    
                                                                                                                        
#define assume __VERIFIER_assume                                                                                        
#define seahorn_assert assert                                                                                           
                                                                                                                        
int unknown1(void);                                                                                                     
                                                                                                                        
int main(void) {                                                                                                        
    int n, k, j;                                                                                                        
    n = unknown1();                                                                                                     
    k = unknown1();                                                                                                     
    j = 0;                                                                                                              
    while( j < n ) {                                                                                                    
        j++;                                                                                                            
        k--;                                                                                                            
    }                                                                                                                   
    seahorn_assert(k>=0);                                                                                               
    return 0;                                                                                                           
}
